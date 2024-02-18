
upload:
ifndef VPN_SERVER_IP
    $(error VPN_SERVER_IP is not set. Please specify remote host)
endif
ifndef SSH_KEY_PATH
    $(error SSH_KEY_PATH is not set.)
endif
ifndef SOURCE_PATH
    $(error SOURCE_PATH is not set.)
endif
ifndef DESTINATION_PATH
    $(error DESTINATION_PATH is not set.)
endif
	@scp -i $(SSH_KEY_PATH) -r admin@$(VPN_SERVER_IP):$(SOURCE_PATH) $(DESTINATION_PATH)

.PHONY: upload
