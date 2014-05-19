declaration template aii/freeipa;

type aii_freeipa = {
    "domain" : type_fqdn # network domain
    "server" : type_hostname # FreeIPA server
    "realm" : string # FreeIPA realm

    "dns" : boolean = true # DNS is controlled by FreeIPA (to register the host ip)
    "disable" : boolean = true # disable the host on AII removal
};
