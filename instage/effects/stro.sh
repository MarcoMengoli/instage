#!/bin/bash

while true; do
mosquitto_pub -h localhost -t "test" -m '{"1":255,"2":255,"3":0,"4":0,"6":255,"7":15,"17":255,"18":0,"19":0,"20":0,"22":255,"23":230,"33":100,"34":255,"35":0,"36":0,"39":0,"41":255}'
sleep 2
mosquitto_pub -h localhost -t "test" -m '{"1":255,"2":0,"3":0,"4":0,"6":255,"7":140,"17":255,"18":0,"19":0,"20":0,"22":255,"23":200,"33":100,"34":255,"35":255,"36":0,"39":0,"41":255}'
sleep 2
mosquitto_pub -h localhost -t "test" -m '{"1":255,"2":0,"3":0,"4":0,"6":255,"7":230,"17":255,"18":0,"19":0,"20":0,"22":255,"23":170,"33":100,"34":0,"35":255,"36":0,"39":0,"41":255}'
sleep 2
mosquitto_pub -h localhost -t "test" -m '{"1":255,"2":0,"3":0,"4":0,"6":255,"7":200,"17":255,"18":0,"19":0,"20":0,"22":255,"23":15,"33":100,"34":0,"35":255,"36":255,"39":0,"41":255}'
sleep 2
mosquitto_pub -h localhost -t "test" -m '{"1":255,"2":0,"3":0,"4":0,"6":255,"7":170,"17":255,"18":0,"19":0,"20":0,"22":255,"23":140,"33":100,"34":0,"35":0,"36":255,"39":0,"41":255}'
sleep 2
mosquitto_pub -h localhost -t "test" -m '{"1":255,"2":0,"3":0,"4":0,"6":255,"7":45,"17":255,"18":0,"19":0,"20":0,"22":255,"23":100,"33":100,"34":255,"35":0,"36":255,"39":0,"41":255}'
sleep 2


done