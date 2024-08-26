# 3 - Setup fstrim for SSD Maintenance and Performance

**1. Install util-linux**

   - **Install the `util-linux` Package**:  
     The script installs the `util-linux` package using `pacman`. This package includes a variety of essential utilities for Linux systems, including `fstrim`, which is used for maintaining SSD performance.

     ```bash
     sudo pacman -S --noconfirm util-linux &> /dev/null
     ```

**2. Enable fstrim Timer**

   - **Enable and Start the `fstrim.timer`**:  
     The script enables and starts the `fstrim.timer` service using `systemctl`. This timer ensures that the `fstrim` command runs periodically to trim unused blocks on SSDs, helping maintain their performance and longevity. By enabling the timer, the system will automatically perform the trim operation at scheduled intervals.

     ```bash
     sudo systemctl enable --now fstrim.timer &> /dev/null
     ```
