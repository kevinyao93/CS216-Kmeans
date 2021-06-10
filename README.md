# CS216 Network Algorithmics Project

### Packet Classification using K-Means on P4 

lolz

To do p4 testing while we develop kmeans: 
```$ P4APP_LOGDIR=./project-files/out p4app run simple_router.p4app/```


Then on another terminal enter the following: 

```
$ p4app exec m h1 bash
$ cd app; python scapy_from_csv.py
```

Now you should see packets flow from h1 over to h2. To view this on wireshark, before running `scapy_from_csv.py`, open another terminal and enter: 

```
p4app exec m h2 tcpdump -Uw - | wireshark -ki -
````


~