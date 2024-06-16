## Installation Script 📥

### Prerequisites 📋

- A device with ARM64 architecture
- Termux installed
- Run `termux-change-repo` once
- At least 4.5GB of free space

### Installation
**Run the following command in Termux:**
```sh
curl -sL tmx.6a67.de/mocri | bash
```
(This downloads and executes a script directly from the internet. Please review the script before running it.)


## Wrapper Script 📜

### Prerequisites 📋

- Termux:API
  - Run `pkg install termux-api` to install it
  - Download and install https://f-droid.org/packages/com.termux.api/

### Installation
**Run the following command in Termux:**
```sh
curl -sL tmx.6a67.de/mocrw | bash
```

### Wrapper Usage 🚀

1. **Make the script executable:**
    ```sh
    chmod +x mocrw
    ```

2. **Run the script:**
    ```sh
    ./mocrw -r screenshots
    ```

### Command Line Options

- `-r, --read_from`: Specify file or directory to read from. Magic values are 'clipboard' and 'screenshots'.
- `-w, --write_to`: Specify file or directory to write to. Magic value is 'clipboard'.
- `-d, --delay`: Delay in seconds between checks.
- `-hd, --hidden`: Include hidden files.
- `-mv, --move`: Move the scanned image to a subdirectory.
- `-sd, --subdirectory`: Subdirectory to move the scanned image to.
- `-n, --notification`: Send a notification after processing an image.
- `-m, --mode`: Script modes: 'continuous', 'manual', 'notification'.

## Sources 📚

- https://wiki.termux.com/wiki/Termux:API
- https://github.com/kha-white/manga-ocr
- https://github.com/Ajatt-Tools/transformers_ocr