# dotfiles

## About

### Environment

WSL2 (Ubuntu) on Windows

### Installing

```bash
git clone https://github.com/motty93/dotfiles.git ~/dotfiles
bash ~/dotfiles/etc/install.sh
```

### Customizing

- Change your `.gitconfig` user info
- Fill in `~/.bash_secrets` with actual values
- Restart the shell (`exec bash`) to load PATH changes
- Re-login or run `newgrp docker` to activate the docker group
