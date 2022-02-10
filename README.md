## sdr-enthusiasts/docker-JAERO

This image is a work in progress. I'm not able to continue, as I con't have a source for the L-band data.

I'm putting this image on-line in case someone want's to fork and continue development.

The original idea was:

* Produce an audio stream from rtl_sdr
* Use pulseaudio to create a virtual audio device, configure JAERO to use it
* Present JAERO GUI in a browser with noVNC

If anyone wants to continue development, I'd suggest:

* Change the base container to [jlesage/docker-baseimage-gui](https://github.com/jlesage/docker-baseimage-gui), instead of doing all the XWindows/noVNC stuff manually.
* Abadon pulseaudio in favour of something else. Since the initial development, JAERO now supports zmq.

Good luck, and if you want to discuss, please [join our Discord](https://discord.gg/sTf9uYF) and say hello in the `#satcom` channel.