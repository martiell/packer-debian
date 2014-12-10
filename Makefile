TARGET=box/vmware
NAME=debian
BOX=box/vmware/$(NAME).box
YAML=$(NAME).yaml vars.yaml
JSON=$(patsubst %.yaml,$(TARGET)/%.json,$(YAML))

all: $(BOX)
json: $(JSON)
install: $(BOX)
	vagrant box add --force $(NAME) $<

$(TARGET):
	mkdir -p $(TARGET)

$(TARGET)/%.json: %.yaml | $(TARGET)
	@printf "%-12s --> %s\n" "$<" "$@"
	@ruby -e "require 'yaml'; require 'json'; \
		puts JSON.pretty_generate( \
		YAML.load(STDIN).reject{|k| k[0] == '_'})" \
		< $< > $@

$(TARGET)/$(NAME).box: $(JSON)
	PACKER_LOG=y \
	PACKER_LOG_PATH=$(TARGET)/$(NAME).log \
	packer build \
	  -only=vmware-iso \
	  -var-file=$(TARGET)/vars.json \
	  $(TARGET)/$(NAME).json

clean:
	rm -r $(TARGET)

.PHONY: all clean install
