# sdr-enthusiasts/docker-JAERO

Docker container for [JAERO](https://github.com/jontio/JAERO) to receive/decode inmarsat ACARS via zmq from [SDRReceiver](https://github.com/jeroenbeijer/SDRReceiver).

---

This container is based on the excellent [jlesage/docker-baseimage-gui](https://github.com/jlesage/docker-baseimage-gui). All the hard work has been done by them, for advanced usage I suggest you check out the [README](https://github.com/jlesage/docker-baseimage-gui/blob/master/README.md) from [jlesage/docker-baseimage-gui](https://github.com/jlesage/docker-baseimage-gui).

---

### Ports `5800` `5900` `30003` are exposed by default in this container.

| Port   | Mapping to host | Description |
|--------|-----------------|-------------|
| `5800` | Mandatory       | Port used to access the application's GUI via the web interface.|
| `5900` | Optional        | Port used to access the application's GUI via the VNC protocol.  Optional if no VNC client is used. |
| `30003`| Optional        | Port used to serve Basestation data. |

### Environment Variables

| Environment Variable | Description |  Default       |
|----------------------|-------------|----------------|
|`TZ`                  |Your local timezone in [TZ-database-name](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) format|  Australia/Melbourne |
|`DISPLAY_WIDTH`       | VNC display width  | `1920`  |
|`DISPLAY_HEIGHT`      | VNC display height | `1080`  |
|`VNC_PASSWORD`        | VNC password       | Unset   |


| Jaero Variables               | Description                                                | Controls Jaero option                    | Default            |
|-------------------------------|------------------------------------------------------------|------------------------------------------|--------------------|
|`SET_STATION_ID`               | Jaero Station Id (airframes feeder ID)                     | Set Station ID                           | Unset              |
|`DISABLE_PLANE_LOGGING`        | Disable plane logging                                      | Disable plane log window                 | `true`             |
|`ENABLE_BASESTATION_FORMAT`    | Enable jaero Basestation output                            | Enable BaseStation format                | `false`            |
|`BASESTATION_ADDRESS`          | IP address and port on which to serve basestation data     | Enable BaseStation format ip:port window | `0.0.0.0:30003`    |
|`BEHAVE_AS_BASESTATION_CLIENT` | Set to true to enable client behaviour                     | Behave as client                         | `false`            |
|`SDRX_ADDRESS`                 | SDRReceiver ip address and port to receive zmq data        | Address                                  | Unset              |
|`SDRX_TOPIC_NAME`              | SDRReceiver topic name                                     | First half of topic setting              | `VFO`              |
|`NUMBER_OF_SDRX_TOPICS`        | Total number of jaero configurations to create based on total number of SDRX vfo's, starting at `01` for a maximum of 25. Update SDRX.ini to match.| Second half of topic setting | `3` |
|`ENABLE_FEEDING`               | Enable feeding                                             | Enable output feeding using UDP          | `true`             |
|`FEEDERS`                      | Add feeders to upload via UDP                              | Adds feeders under JAERO feeding window with format:host:port | `1\format=4 1\host=feed.airframes.io 1\port=5571` |

`FEDDERS` format for jaero output is `3` for json and `4` for jsondump.
Add more feeders by incrementing the first digit. See example entry in [`docker-compose.yml`](docker-compose.yml)

## Up-and-Running with `docker-compose` 

- An example [`docker-compose.yml`](docker-compose.yml) file can be found in this repository.

Once you have [installed Docker](https://github.com/sdr-enthusiasts/docker-install), you can follow these lines of code to get up and running:

```bash
mkdir -p docker-jaero
cd docker-jaero
wget https://raw.githubusercontent.com/sdr-enthusiasts/docker-jaero/main/docker-compose.yml
```

- Edit the `docker-compose.yml` and make any changes as needed.

Start the Container

```bash
docker compose up -d
```
- Browse to `http://your-host-ip:5800` to access the GUI.
- Set JAERO settings ( speed and locking ) as defined in SDRX.ini
