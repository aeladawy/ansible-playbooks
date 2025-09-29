#! /bin/bash

# dynatrace agent installation is controlled at service level. but we might not want to install it on
# certain host groups regardless of service. In such case, set "exclude_dynatrace = true" at the group level.

cat << EOS
{
    "common": {
        "vars": {
            "role": "infra"
        },
        "children": [
            "cdp",
            "splunk",
            "appnodes",
            "datanodes",
            "kts",
            "tower",
	    "ldap",
            "ldap_provider",
            "ldap_replica",
            "ldap_zone",
            "postfix",
            "panhc",
            "dtproxy",
            "dtnetmon",
            "kms",
            "pws",
            "arches",
            "stratus",
            "prodpci",
            "moogsoft",
            "vaultintegratedstorage",
            "cm_kts",
            "apollojenkins"
        ]
    },
    "appnodes": {
        "children": [
            "copyhost",
            "dumphost",
            "products",
            "sendmail",
            "stratus",
            "web"
        ]
    },
    "datanodes": {
        "vars": {
            "role": "db"
        },
        "children": [
            "cassandra",
            "cdh",
            "hana",
            "hanatool",
            "influx",
            "kafka",
            "mongodb",
            "postgres",
            "redis",
            "cdp"
        ]
    },
    "products": {
        "vars": {
            "role": "app"
        },
        "children": [
            "an",
            "arches",
            "auc",
            "buyer",
            "clamav",
            "clamavng",
            "clamav_v3",
            "freshclammirror",
            "freshclammirror_v3",
            "dms",
            "gb",
            "mobile",
            "mon",
            "s4",
            "sm",
            "spotbuy",
            "sr",
            "hanasim"
        ]
    },
    "arches": {
        "vars": {
            "product": "arches",
            "role": "other"
        },
        "children": [
            "arches_idx",
            "arches_sc",
            "lbl_app_arches"
        ]
    },
    "cdp": {
        "children": [
            "cmcs_cdp",
            "cmms_cdp",
            "arches_cdp",
            "cms_cdp",
            "audit_cdp",
            "kdc_cs",
            "kdc_ms",
            "lbl_app_kdc_cs",
            "lbl_app_kdc_ms",
            "lbl_app_cmms_cdp",
            "lbl_app_cmcs_cdp"
        ]
    },
    "kms": {
        "vars": {
            "product": "kms",
            "role": "infra"
        },
        "children": [
            "kmsconsul",
            "kmsvault",
            "kmsconsuldns"
        ]
    },
    "hanasim": {
        "children": [
            "lbl_app_hanasim"
        ]
    },
    "kmsconsul": {
        "children": [
            "lbl_app_kmsconsul"
        ]
    },
    "vaultintegratedstorage": {
        "children": [
            "lbl_app_vaultintegratedstorage"
        ]
    },
    "kmsvaultcerts": {
        "children": [
            "lbl_certs_kmsvault"
        ]
    },
    "kmsconsulcerts": {
        "children": [
            "lbl_certs_kmsconsul"
        ]
    },
    "kmsvault": {
        "children": [
            "lbl_app_kmsvault"
        ]
    },
    "kmsconsuldns": {
        "children": [
            "lbl_app_kmsconsuldns"
        ]
    },
    "stratus": {
        "children": [
            "grafana",
            "kapacitor"
        ]
    },
    "pws": {
        "vars": {
            "product": "pws",
            "role": "web"
        },
        "children": [
            "lbl_app_pws"
        ]
    },
    "web": {
        "vars": {
            "role": "web"
        },
        "children": [
            "adm",
            "cws",
            "ows",
            "ssws",
            "ws"
        ]
    },
    "network": {
        "children": [
            "pan"
        ]
    },
    "auc": {
        "vars": {
            "product": "community"
        },
        "children": [
            "lbl_app_auc"
        ]
    },
    "buyer": {
        "vars": {
            "product": "buyer"
        },
        "children": [
            "lbl_app_buyer"
        ]
    },
    "cassandra": {
        "vars": {
            "role": "db/cassandra"
        },
        "children": [
            "lbl_app_cassandra",
            "lbl_app_search3_cassandra",
            "lbl_app_shared_cassandra"
        ]
    },
    "influx": {
        "vars": {
            "role": "db/influxdb",
            "exclude_dynatrace": "true"
        },
        "children": [
            "lbl_app_influxdb"
        ]
    },
    "lbl_app_influxdb": {
        "children": [
            "lbl_influxdb-meta",
            "lbl_influxdb-data"
        ]
    },
    "cdh": {
        "vars": {
            "role": "db/hadoop"
        },
        "children": [
            "lbl_app_cdh",
            "lbl_app_search3_cdp",
            "lbl_app_arches_cdp",
            "lbl_app_cms_cdp",
            "lbl_app_audit_cdp",
            "lbl_app_kdc_ms",
            "lbl_app_kdc_cs"
        ]
    },
    "clamav": {
        "vars": {
            "product": "clamavadapter",
            "role": "app"
        },
        "children": [
            "lbl_app_clamav"
        ]
    },
    "clamavng": {
        "vars": {
            "product": "clamavadapter",
            "role": "app"
        },
        "children": [
            "lbl_app_clamavng"
        ]
    },
    "clamav_v3": {
        "vars": {
            "product": "clamavadapter",
            "role": "app"
        },
        "children": [
            "lbl_app_clamav_v3"
        ]
    },
    "freshclammirror": {
        "vars": {
            "product": "clamavadaptor",
            "role": "other"
        },
        "children": [
            "lbl_app_freshclam"
        ]
    },
    "freshclammirror_v3": {
        "vars": {
            "product": "clamavadaptor",
            "role": "other"
        },
        "children": [
            "lbl_app_freshclam_v3"
        ]
    },
    "dms": {
        "vars": {
            "product": "dms"
        },
        "children": [
            "lbl_app_dms"
        ]
    },
    "hana": {
        "vars": {
            "role": "db/hana"
        },
        "children": [
            "lbl_app_hana"
        ]
    },
    "hanatool": {
        "vars": {
            "role": "db/hanatool"
        },
        "children": [
            "lbl_app_hana_kms_tool"
        ]
    },
    "gb": {
        "vars": {
            "product": "gb"
        },
        "children": [
            "lbl_app_gb"
        ]
    },
    "kafka": {
        "vars": {
            "role": "db/kafka"
        },
        "children": [
            "lbl_app_kafka",
            "lbl_app_cmcs_kafka",
            "lbl_app_cmms_kafka"
        ]
    },
    "mongodb": {
        "vars": {
            "role": "db/mongodb"
        },
        "children": [
            "lbl_app_mongodb"
        ]
    },
    "mobile": {
        "vars": {
            "product": "mobile"
        },
        "children": [
            "lbl_app_mobile"
        ]
    },
    "mon": {
        "vars": {
            "product": "mon",
            "role": "mon"
        },
        "children": [
            "lbl_app_mon"
        ]
    },
    "moogsoftcerts": {
        "children": [
            "lbl_certs_moogsoft"
        ]
    },
    "moogsoft": {
        "children": [
            "lbl_app_moogsoft"
        ]
    },
    "copyhost": {
        "vars": {
            "product": "shared",
            "role": "other"
        },
        "children": [
            "lbl_app_copyhost"
        ]
    },
    "dumphost": {
        "vars": {
            "product": "shared",
            "role": "other"
        },
        "children": [
            "lbl_app_dumphost"
        ]
    },
    "an": {
        "vars": {
            "product": "an"
        },
        "children": [
            "lbl_app_an"
        ]
    },
    "s4": {
        "vars": {
            "product": "s4"
        },
        "children": [
            "lbl_app_s4"
        ]
    },
    "sm": {
        "vars": {
            "product": "suppliermanagement"
        },
        "children": [
            "lbl_app_sm"
        ]
    },
    "spotbuy": {
        "vars": {
            "product": "spotbuy"
        },
        "children": [
            "lbl_app_spotbuy"
        ]
    },
    "sr": {
        "vars": {
            "product": "supplierrisk"
        },
        "children": [
            "lbl_app_sr"
        ]
    },
    "adm": {
        "children": [
            "lbl_app_adm"
        ]
    },
    "cws": {
        "vars": {
            "product": "cws"
        },
        "children": [
            "lbl_app_cws"
        ]
    },
    "ows": {
        "vars": {
            "product": "ows"
        },
        "children": [
            "lbl_app_ows"
        ]
    },
    "ssws": {
        "vars": {
            "product": "ssws"
        },
        "children": [
            "lbl_app_ssws"
        ]
    },
    "ws": {
        "vars": {
            "product": "ws"
        },
        "children": [
            "lbl_app_ws"
        ]
    },
    "sendmail": {
        "vars": {
            "product": "sendmail",
            "role": "infra"
        },
        "children": [
            "lbl_app_sendmail"
        ]
    },
    "grafana": {
        "children": [
            "lbl_app_grafana",
            "lbl_grafana_",
            "lbl_app_stratus"
        ]
    },
    "kapacitor": {
        "children": [
            "lbl_app_kapacitor",
            "lbl_kapacitor_",
            "lbl_app_stratus"
        ]
    },
    "splunk": {
        "vars": {
            "product": "splunk",
            "role": "other",
            "exclude_dynatrace": "true"
        },
        "children": [
            "lbl_app_splunk"
        ]
    },
    "kts": {
        "children": [
            "lbl_app_kts",
            "lbl_app_cm_kts"
        ]
    },
    "ldap": {
        "vars": {
            "role": "infra"
        },
        "children": [
            "lbl_app_ldap_provider",
            "lbl_app_ldap_replica",
            "lbl_app_ldap_zone"
        ]
    },
    "ldap_provider": {
        "vars": {
            "role": "infra"
        },
        "children": [
            "lbl_app_ldap_provider"
        ]
    },
    "ldap_replica": {
        "vars": {
            "role": "infra"
	},
        "children": [
            "lbl_app_ldap_replica"
        ]
    },
    "ldap_zone": {
        "vars": {
            "role": "infra"
        },
        "children": [
            "lbl_app_ldap_zone"
        ]
    },
    "panhc": {
        "children": [
            "lbl_app_panhc"
        ]
    },
    "postfix": {
        "vars": {
            "product": "postfix",
            "role": "infra",
            "ansible_python_interpreter": "/usr/bin/python3"
        },
        "children": [
            "lbl_app_postfix",
            "lbl_app_smtp",
            "smtp"
        ]
    },
    "redis": {
        "vars": {
            "role": "db/redis"
        },
        "children": [
            "lbl_app_redis"
        ]
    },
    "postgres": {
        "vars": {
            "role": "db/postgres"
        },
        "children": [
            "lbl_app_postgres"
        ]
    },
    "tower": {
        "vars": {
            "exclude_dynatrace": "true"
        },
        "children": [
            "lbl_app_tower"
        ]
    },
    "prodpci": {
        "vars": {
            "exclude_dynatrace": "true"
        },
        "children": [
            "lbl_opsservice_prodpci"
        ]
    },
    "freshclammirrow": {
        "children": [
            "lbl_app_freshclam"
        ]
    },
    "yumrepo": {
        "vars": {
            "role": "infra"
        },
        "children": [
            "lbl_app_yumrepo"
        ]
    },
    "dtproxy": {
        "vars": {
            "product": "dynatrace",
            "role": "infra"
        },
        "children": [
            "lbl_app_dtproxy"
        ]
    },
    "dtnetmon": {
        "vars": {
            "product": "dynatrace",
            "role": "infra"
        },
        "children": [
            "lbl_app_dtnetmon"
        ]
    },
    "apollojenkins": {
        "vars": {
            "role": "infra"
        },
        "children": [
            "lbl_app_apollojenkins"
        ]
    }
}

EOS
