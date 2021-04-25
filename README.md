# Iron Gauntlet

This repository contains circuit diagrams and software (for the Raspberry Pi 3/Pi Zero W) to turn the toy [Avengers Marvel Legends Series Endgame Power Gauntlet Articulated Electronic Fist](https://www.amazon.com/gp/product/B07P7WZF11) into an Alexa-enabled smart device with independent control of each of the Infinity stones and a cool, ambient effect using pulse width modulation to control brightness.

![IronGauntlet](images/IronGauntlet.gif)

While there is an included circuit diagram and a couple images of the physical wiring itself, the focus of this repository is on the software. In particular, it turns this device into a ready to boot-and-use appliance using [pi-bootstrap](https://github.com/aniongithub/pi-bootstrap). It is primarily intended to be a starting point for other projects - showcasing modern distribution tooling to developers working on Linux single-board-computers.

## Circuit diagram & physical wiring

The glove can be disassembled using a Philips head screwdriver and several layers have to taken off to reveal the gray plastic that houses the SMD leds. You can remove the circuit boards containing the LEDs and chip-on-board to replace the LEDs with [these](https://www.amazon.com/CHANZON-PC-59042-Emitting-Assorted-Arduino/dp/B01AUI4VSI/ref=pd_ybh_a_20?_encoding=UTF8&psc=1&refRID=JCP5C1KQ5P37ZX6H5M1F), or you can choose to solder leads directly onto the boards and cut the wires (and some of the tracks) between the LEDs and the chip-on-board that's by the Mind stone LED.

![Physical wiring](images/LED-leads.gif)

I tested that everything was working using a bread board and a 40-pin GPIO breakout. Here's the circuit diagram. Since I had a lot of GPIO pins to spare, I used up 6 of them. You can also use a shift register like the 74HC595 to control the 6 LEDs (it has 8 bit parallel output) using just 3 pins. My testing procedure using the CLI `gpio` is detailed below in the software section.

![Circuit Diagram](images/circuit.png)

Once everything was tested, I soldered the components onto a [breadboard hat](https://www.amazon.com/gp/product/B07C54DP8T) (with a 40-pin female header) and attached it to the Raspberry Pi (Zero W). After re-assembling the gauntlet, it was time to put get all the software going.

## Software

### Installation (Github Actions)

As a [pi-bootstrap](https://github.com/aniongithub/pi-bootstrap) based appliance, all you need to do in order to use this software is:

1. Click ![image-20210416222151898](/home/ani/Projects/pi-bootstrap/media/image-20210416222151898.png)and create a new public/private repository in your account based on this template.
   
   :warning: *If you plan to use this repository to create a ready-to-use image that includes your Wi-Fi SSID, passphrase or other private information, it is recommended to create a private repository at this stage*
   
2. Navigate to ![image-20210416225541954](/home/ani/Projects/pi-bootstrap/media/image-20210416225541954.png)and then ![image-20210416225617502](/home/ani/Projects/pi-bootstrap/media/image-20210416225617502.png) (in the sidebar)

3. Add secrets and values for the following supported arguments as required. Note that if you skip adding a secret (think of secrets as an override to the default value), the default value for that argument will be used instead.

   :gear: *If you're a developer creating templates for other users, you can skip this step to use safe defaults you can test with*

| Name                | Description                                                  |
| ------------------- | ------------------------------------------------------------ |
| **IMAGE_NAME**      | This is the name of the generated image. Defaults to the name of the repository you created in step 1 |
| **FIRST_USER**      | The username of the first user on the generated image. Defaults to *pi* |
| **FIRST_USER_PASS** | The password for the first user on the generated image. Defaults to *raspberry* |
| **HOSTNAME**        | The name with which your newly booted pi will identify itself to any networks. Defaults to *IMAGE_NAME* |
| **SSH_ENABLED**     | 1 to enable SSH, 0 to disable SSH. Defaults to *1*           |
| **WPA_COUNTRY**     | [Two-character ISO-3166-1 alpha-2 country code](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) for your country. *Not setting this will keep Wi-Fi disabled via rfkill* |
| **WPA_SSID**        | SSID of your Wi-Fi network, if you want to enable Wi-Fi connectivity. *Not setting this will keep Wi-Fi disabled via rfkill* |
| **WPA_PASSPHRASE**  | Passphrase of your Wi-Fi network, if you want to enable Wi-Fi connectivity. *Not setting this will keep Wi-Fi disabled via rfkill* |

4. Navigate to the ![image-20210416231117301](/home/ani/Projects/pi-bootstrap/media/image-20210416231117301.png) tab and then edit [bootstrap/00-packages](bootstrap/00-packages) to add or remove any packages your custom image might need

5. Optionally, you can edit [config](config), [bootstrap/01-run.sh](bootstrap/01-run.sh) and/or [bootstrap/02-run.sh](bootstrap/02-run.sh) to add, remove or re-order custom installation steps and commit your changes
   :gear: See [raspotify-appliance](https://github.com/aniongithub/raspotify-appliance/blob/4630f5e29d3b1fb35e4e65169327b97377b4f06a/.github/workflows/release.yml#L54) for an example of how to add custom secrets (`DEVICE_NAME`) that are then propagated to [config](config) via [pi-gen/build-docker.sh](pi-gen/build-docker.sh) to any custom build steps you create

6. If you want to build an image for testing, navigate to ![image-20210416232008223](/home/ani/Projects/pi-bootstrap/media/image-20210416232008223.png)and select the ![image-20210424193432121](/home/ani/Projects/pi-bootstrap/media/image-20210424193432121.png) workflow. You can then pick the branch want to build the test image with:
   ![image-20210416232231819](/home/ani/Projects/pi-bootstrap/media/image-20210416232231819.png)

   *:gear: You can also use the `Manual` workflow for a fully parameterized run without using secrets. However, be aware that any private information will show up in logs for that run.*

7. Click ![image-20210416232332897](/home/ani/Projects/pi-bootstrap/media/image-20210416232332897.png) and wait for the workflow run to finish. This may take 30+ minutes, depending on the packages and custom installation steps you've selected

   :warning: Free Github accounts only come with 2000 minutes of (Linux) Actions usage per month, so be careful with your usage minutes!

8. Once the workflow completes successfully, you will be able to download the image it built for you

   :warning: Make sure to delete or hide any artifacts that may contain sensitive information. Your secrets will not be propagated to any repositories created using your template, but artifacts and logs may be visible to anyone who can see the repository

9. Burn the image from step 8 onto a micro-SD card using [Imager](https://www.raspberrypi.org/software/), [Etcher](https://www.balena.io/etcher/) or another program of you choice

10. Insert the micro-SD card into your pi, power it up and wait for it to boot. Repeat steps 4-10 as needed

11. Once you're happy with your custom image, you can create a release to lock in that configuration for posterity. Go to the ![image-20210416231117301](/home/ani/Projects/pi-bootstrap/media/image-20210416231117301.png)tab and click ![image-20210416233657764](/home/ani/Projects/pi-bootstrap/media/image-20210416233657764.png)on the right. Enter your release details and hit ![image-20210416233817873](/home/ani/Projects/pi-bootstrap/media/image-20210416233817873.png)

12. Wait for the `Release` workflow to finish and you should see your new release appear in the ![image-20210416234024343](/home/ani/Projects/pi-bootstrap/media/image-20210416234024343.png) section along with your newly-minted image (and the source code packages it was built from)

13. Burn your custom image onto a microSD card using [Imager](https://www.raspberrypi.org/software/) or [Etcher](https://www.balena.io/etcher/) and start using it in your Raspberry pi!

### Installation (Manual)

* Clone or copy this repo anywhere on your pi
* Run `sudo ./install.sh` from a terminal to install dependencies and the software to `/etc/iron-gauntlet`

### Troubleshooting

- To effectively troubleshoot the device you'll need to SSH into it, so make sure that you have an image that is capable of connecting to your network (either via LAN cable or Wi-Fi)
  `ssh <FIRST_USER>@<HOSTNAME>/<IP>` which, using defaults would be `ssh pi@iron-gauntlet`
  :gear: Note that if you're on Linux (or WSL), you have to append `.local` to the hostname in order to ping it. 

- Since the `iron-gauntlet` service runs on boot, you can stop it using

  `sudo systemctl stop iron-gauntlet` (this has a timeout of 5 seconds)

- You can also start it using

  `sudo systemctl start iron-gauntlet`

- To see (and follow) the logs for the `iron-gauntlet` service, use `journalctl -u iron-gauntlet -f -b`. The `-b` option only shows logs for the current boot, so omit that if you would like to see the logs from previous boots as well

### Testing

To do this, ensure you've followed the installation steps from the section above and put together the circuit as shown, either on a breadboard or using soldered components. Since the `iron-gauntlet` service runs on boot, you can stop it using

`sudo systemctl stop iron-gauntlet` (this has a timeout of 5 seconds)

You can also start it using

`sudo systemctl start iron-gauntlet`

While performing breadboard testing, it's useful to blink a single LED attached to a GPIO pin so you can ensure the on-gauntlet connection to the LED works correctly.

`ssh <user>@<hostname/IP-of-your-appliance>`

You should then be able to type

`gpio -1 blink 11` into the terminal to make a single LED connected to physical GPIO pin 11 blink.

The `-1` option makes GPIO use phyiscal pin numbers, which are also used in `InfinityStone.py`. Now you can ensure that the connections to your LEDs are correct and steady before/after soldering things together.
