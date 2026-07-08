# benny-cservice
A Extensive FiveM (ESX, QBox, QbCore, Standalone) Community Service Script 

preview: https://youtu.be/xIUzbpB0JMA 


# dependencies
- ox_lib (required)
- oxmysql (required)
- benny-textui (optional) https://github.com/benny1x/benny-textui

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






# Benny Software License (BSL) v1.0

Copyright (c) 2026 Benny. All Rights Reserved.

By downloading, purchasing, obtaining, or using this software, you agree to the following terms.

## You MAY

- Use this resource on your own FiveM server(s).
- Modify the resource for your own personal or server use.
- Create integrations or configuration changes for your own server.

## You MAY NOT

- Sell, resell, lease, rent, sublicense, or otherwise commercially distribute this resource or any modified version of it.
- Redistribute, share, upload, or publish the source code, in whole or in part, whether free or paid.
- Repackage this resource as your own release.
- Claim ownership or authorship of any part of this resource.
- Remove, alter, or obscure any copyright notices, credits, or licensing information.
- Include this resource in any leak, dump, repository, archive, or file-sharing service.
- Reverse engineer, copy, or recreate substantial portions of this resource for the purpose of producing a competing product.
- Use this source code, or any modified version of it, to train, fine-tune, evaluate, improve, or develop any machine learning model, large language model (LLM), artificial intelligence system, code generation model, dataset, or similar technology.
- Submit, upload, or provide any portion of this source code to any AI or LLM service for training, analysis, learning, or dataset creation without prior written permission from the copyright holder.

## Ownership

This resource is licensed, not sold.

All intellectual property rights remain the exclusive property of Benny.

Purchasing or obtaining a copy grants you a limited, non-exclusive, non-transferable, revocable license to use the resource in accordance with this license.

## Termination

Any violation of these terms immediately terminates your license to use this resource.

Upon termination, you must cease use of the resource and delete all copies in your possession or control.

## Disclaimer

This software is provided "AS IS", without warranty of any kind, express or implied. The author shall not be liable for any damages arising from the use or inability to use this software.

## Contact

For licensing questions or permissions beyond those granted in this license, contact Benny.



