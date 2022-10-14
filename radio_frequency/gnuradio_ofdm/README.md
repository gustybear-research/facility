# Installation

The following installation instructions were tested on the following OSes:
- Ubuntu 20.04.2
- Ubuntu 14.04.4

The GNURadio installation procedures were conducted as follows:

Install pip, a Python package manager.
```
$ cd
$ sudo apt-get install python3-pip
```

Install Pybombs, a Python environment manager.
```
$ sudo pip3 install pybombs
$ pybombs auto-config
```

Add the GNURadio recipes using Pybomb and store it in the folder ~/prefix-3.8.
```
$ pybombs recipes add-defaults
$ pybombs prefix init ~/prefix-3.8 -R gnuradio38
```

Load the new shell/terminal environment.
```
$ source ~/prefix-3.8/setup_env.sh
```

Install gr-ieee-80211 and all related repositories.
```
$ pybombs install gr-ieee-80211
```

Note that since we are using GNURadio 3.8, we need to modify the Pybomb recipes for gr-osmosdr.

To modify the Pybomb recipes, open the lwr files for gr-osmosdr and gr-iqbal. Replace the line with `gitbranch: 'master'` with `gitbranch: 'gr3.8'`. An example can be seen below:
```
$ nano ~/.pybombs/recipes/gr-recipes/gr-osmosdr.lwr
$ nano ~/.pybombs/recipes/gr-recipes/gr-iqbal.lwr
TO CHANGE: gitbranch: 'master' -> gitbranch: 'gr3.8'
```

Install gr-osmosdr module with Pybomb.
```
$ pybombs install gr-osmosdr
```

Enable multithreading.
```
$ sudo nano /etc/security/limits.conf
INSERT: @<user> - rtprio 99
```

Increase read and write memory buffer.
```
$ sudo nano /etc/sysctl.conf
INSERT FOLLOWING:
net.core.rmem_max=50000000
net.core.wmem_max=2500000
```

Calibrate uhd system.
```
$ uhd_cal_rx_iq_balance; uhd_cal_tx_dc_offset; uhd_cal_tx_iq_balance
```

Build the ~/prefix-3.8/src/gr-ieee-80211/examples/wifi_phy_hier.grc by running it in GNURadio.

Test your installation by running GNURadio ~/prefix-3.8/src/gr-ieee-80211/examples/wifi_loopback.grc.
```
$ gnuradio-companion
```

# TX/RX Scripts
Install the TX/RX scripts by downloading them from intrepid (TX) and excalibur (RX).

If the destination computer is connected to LAN and intrepid/excalibur are active, you can copy the files with the following on the destination computer:
```
$ scp yao@<IP_ADDRESS_TX/RX> ~/works* ~/
```

# Modification
If you modify a module, to rebuild, use the following command (```gr-ieee-80211``` is used as an example of rebuilding just one "folder":
```
$ pybombs -p ~/prefix-3.8/ rebuild gr-ieee-80211
```
