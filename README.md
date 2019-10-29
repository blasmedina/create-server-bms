# create-server-bms

https://dev.to/bogdaaamn/run-your-nodejs-application-on-a-headless-raspberry-pi-4jnn

[PM2] Freeze a process list on reboot via:
$ pm2 save

[PM2] Remove init script via:
$ pm2 unstartup systemd

https://www.slashroot.in/sites/default/files/Zone%20file%20example%20with%20its%20contents_0.png

```
$ttl 3600
blasmedina.cl.  IN  SOA raspberry. root.blasmedina.cl. (
            2019092702
            10800
            3600
            604800
            3600 )
@                   IN  NS  blasmedina.cl.
@                   IN  NS  secundario.nin.cl.
blasmedina.cl.              IN  A   181.43.93.220
ns1.blasmedina.cl.          IN  A   181.43.93.220
www                 IN  CNAME   blasmedina.cl.
apps                    IN  CNAME   blasmedina.cl.
_acme-challenge.blasmedina.cl.  1   IN  TXT "cfl9U4aJbzfatSG9jyL_JQl6lV6hRtXzGcUPXqsVcOY"
_acme-challenge.blasmedina.cl.  1   IN  TXT "WF4_xGNJ5Li6TSlzfHdiKcaOTa9g_A8GNBxTa4Wfhx0"
```

```
$ttl 3600
$ORIGIN blasmedina.cl.
@   IN  SOA raspberry. root.blasmedina.cl. (
        2019092705
        10800
        3600
        604800
        3600
    )
                                    IN  NS      secundario.nin.cl.
                                    IN  NS      ns1.blasmedina.cl.
ns1                                 IN  A       181.43.93.220
www                                 IN  CNAME   blasmedina.cl.
apps                                IN  CNAME   blasmedina.cl.
_acme-challenge.blasmedina.cl.  1   IN  TXT     "cfl9U4aJbzfatSG9jyL_JQl6lV6hRtXzGcUPXqsVcOY"
_acme-challenge.blasmedina.cl.  1   IN  TXT     "WF4_xGNJ5Li6TSlzfHdiKcaOTa9g_A8GNBxTa4Wfhx0"
```