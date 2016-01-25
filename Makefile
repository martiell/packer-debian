NAME=debian
OUT=box
PRESEED=http/preseed.cfg
YAML=$(NAME).yaml vars.yaml
JSON=$(patsubst %.yaml,$(OUT)/%.json,$(YAML))

all: vmware virtualbox
json: $(JSON)
vmware: $(OUT)/vmware/$(NAME).box
virtualbox: $(OUT)/virtualbox/$(NAME).box

%-install: $(OUT)/%/$(NAME).box
	vagrant box add --force $(NAME)-$* $<

$(OUT):
	mkdir -p $(OUT)
$(OUT)/%/.:
	mkdir -p $(dir $@)
.PRECIOUS: $(OUT)/%/.

http:
	mkdir -p http
$(PRESEED): preseed.cfg vars.yaml | http
	@printf "%-12s --> %s\n" "$<" "$@"
	@ruby -e "require 'yaml'; require 'erb'; require 'ostruct'; \
		m = YAML.load(File.new('vars.yaml')) ;\
	        s = Hash[m.map{ |k,v| [k.to_sym,v] }]; \
	        class A < OpenStruct; def render(t) ERB.new(t).result(binding); end; end; \
	        puts A.new(s).render(STDIN.read)" \
		< $< > $@

$(OUT)/%.json: %.yaml | $(OUT)
	@printf "%-12s --> %s\n" "$<" "$@"
	@ruby -e "require 'yaml'; require 'json'; \
		puts JSON.pretty_generate( \
		YAML.load(STDIN).reject{|k| k[0] == '_'})" \
		< $< > $@

.SECONDEXPANSION:

$(OUT)/%/$(NAME).box: $(JSON) $(PRESEED) | $$(@D)/.
	PACKER_LOG=y \
	PACKER_LOG_PATH=$(dir $@)$(NAME).log \
	packer build \
	  -only=$*-iso \
	  -var-file=$(OUT)/vars.json \
	  $(OUT)/$(NAME).json

clean:
	rm -rf $(OUT) $(PRESEED)

.PHONY: all clean install
