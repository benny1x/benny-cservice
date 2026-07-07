# benny-cservice
A Extensive FiveM (ESX, QBox, QbCore, Standalone) Community Service Script 

preview: https://youtu.be/xIUzbpB0JMA 


# dependencies
- ox_lib (required)
- oxmysql (required)

## Configuration

Everything can be configured inside `config.lua` to fit your server.

### Core

| Setting | Description |
|---------|-------------|
| `Config.m_debug` | Enables debug prints for troubleshooting. |
| `Config.m_framework` | Select your framework (`auto`, `esx`, `qb`, `qbox`, `standalone`, `custom`). `auto` will detect it automatically. |
| `Config.m_inventory` | Inventory integration (`auto`, `ox_inventory`, `qb-inventory`). |
| `Config.m_notify` | Notification system (`auto`, `ox_lib`, `esx`, `qb`). |

---

### Text UI

Choose which text UI resource is used when players interact with community service tasks.

```lua
Config.m_text_ui = {
    m_provider = 'benny-textui',
    m_position = 'right-center',
    m_accent = 'orange',
    m_key = 'E',
}
```

| Setting | Description |
|---------|-------------|
| `m_provider` | Text UI resource to use. |
| `m_position` | Where the prompt appears on screen. |
| `m_accent` | Accent colour (used by supported text UIs). |
| `m_key` | Key shown in the interaction prompt. |

---

### Locale

Every notification, command description, HUD label, and interaction message can be changed in one place without editing the script itself.

---

### Commands

```lua
Config.m_commands = {
    m_assign = 'comserv',
    m_remove = 'endcomserv',
    m_check = 'checkcomserv',
}
```

Change the admin commands to whatever fits your server.

---

### Debug Commands

Enable a few helper commands while testing.

```lua
Config.m_debug_commands = {
    m_enabled = true,
}
```

These let you quickly start, stop, or check community service without needing another player.

---

### Permissions

Control who can assign or remove community service.

Supports:

- ACE permissions
- Framework groups
- Job restrictions
- Custom permission callbacks

---

### Item Handling

```lua
Config.m_items = {
    m_mode = 'store_return',
}
```

Available modes:

| Mode | Description |
|------|-------------|
| `none` | Leave player inventory untouched. |
| `store_return` | Store items while in community service and return them afterwards. |
| `permanent_remove` | Remove all items permanently. |

---

### Release Settings

Choose where players are sent once they finish.

```lua
Config.m_release = {
    m_mode = 'fixed_locations',
    m_use_random = true,
}
```

Supports releasing players at fixed locations or back where they originally were.

---

### Community Service Zone

```lua
Config.m_zone
```

Controls:

- Community service area
- Zone radius
- Anti-leave checks
- Vehicle restrictions
- Weapon disabling

If a player leaves the area they'll automatically be moved back inside.

---

### Markers

```lua
Config.m_markers
```

Customize:

- Marker style
- Colour
- Size
- Draw distance
- Interaction distance
- GPS waypoint

---

### Task Settings

General behaviour shared across every task.

Options include:

- Ground snapping
- Spot cooldowns
- Random task selection
- Ground offset adjustments

---

### Tasks

Each task has its own configuration.

```lua
Config.m_tasks = {
    m_sweep = { ... },
    m_garden = { ... },
}
```

Every task can have its own:

- Work area
- Animation
- Prop
- Task duration
- Interaction key
- Marker icon
- Individual locations

Adding your own task type is as simple as creating another entry inside `Config.m_tasks`.

---

### HUD

Choose how remaining tasks are displayed.

```lua
Config.m_hud = {
    m_enabled = true,
    m_style = 'panel',
}
```

Available styles:

- `panel` – Modern UI panel.
- `text` – Simple GTA text.

You can also adjust the position, colours, fonts, and progress display to match your server's look.
