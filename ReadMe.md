# Instructions


## Start supercollider

```bash
nix develop
superdirt
sudo prlimit --memlock=150000000 --rtprio=95 --pid=$$
```

## Start tidal

```bash
nix develop
tidalnvim example.tidal
```

Use `ctl-E` to execute lines in neovim.


## Optional: Start the visualizer

1. Start processing: `processing`.
2. Make sure the processor preferences point to the local `sketchbook/` folder here.
3. Open `sketchbook/didacticpatternvisualizer/didacticpatternvisualizer.pde`.
4. Press the play button.