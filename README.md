# fmoneywashv2
Stripclub Moneywash

You will need:
- QB / QBX or make it work for your own
- ox_lib
- OX radial menu or convert to own
- PolyZone

```
    ['blackmoney']           = { label = 'Blackmoney', weight = 0, stack = true, close = true, buttons = { { label = "Roll", action = function(slot) TriggerEvent('sublime_moneywash:Client:RollMoney') end } } },  -- same weight as cash
```
