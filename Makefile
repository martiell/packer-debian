TARGET=box/vmware
NAME=debian
BOX=box/vmware/$(NAME).box
PRESEED=http/preseed.cfg
YAML=$(NAME).yaml vars.yaml
JSON=$(patsubst %.yaml,$(TARGET)/%.json,$(YAML))

all: $(BOX)
json: $(JSON)
install: $(BOX)
	vagrant box add --force $(NAME) $<

$(TARGET):
	mkdir -p $(TARGET)

$(PRESEED): preseed.cfg
	@printf "%-12s --> %s\n" "$<" "$@"
	@ruby -e "require 'yaml'; \
		m = YAML.load(File.new('vars.yaml')) ;\
	        s = Hash[m.map{ |k,v| [k.to_sym,v] }]; \
		puts STDIN.read % s" \
		< $< > $@

$(TARGET)/%.json: %.yaml | $(TARGET)
	@printf "%-12s --> %s\n" "$<" "$@"
	@ruby -e "require 'yaml'; require 'json'; \
		puts JSON.pretty_generate( \
		YAML.load(STDIN).reject{|k| k[0] == '_'})" \
		< $< > $@

$(TARGET)/$(NAME).box: $(JSON) $(PRESEED)
	PACKER_LOG=y \
	PACKER_LOG_PATH=$(TARGET)/$(NAME).log \
	packer build \
	  -only=vmware-iso \
	  -var-file=$(TARGET)/vars.json \
	  $(TARGET)/$(NAME).json

clean:
	rm -rf $(TARGET) $(PRESEED)

.PHONY: all clean install
