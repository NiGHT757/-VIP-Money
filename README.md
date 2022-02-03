# [VIP] Money
Modified version of [[VIP] Money](https://hlmod.ru/resources/vip-money.546/)

# Features:
Plugin functionality is disabled on **awp_** , **fy_** , **35hp _** , **aim_** maps and in the first rounds.

# Requirements:
[VIP Core](https://github.com/R1KO/VIP-Core) and [SourceMod](https://www.sourcemod.net/downloads.php?branch=stable) 1.10 or higher

# Instalation
1. Unpack and upload the plugin on the server
2. Add **"Money" "Value"** in **groups.ini**, replace **Value** with:
    - **16000** will set 16000 money on spawn.
    - **++4000** will give +4000 money on spawn.
3. Open **vip_modules.phrases.txt** and add
```cpp
    "Armor"
    {
        "ru"        "Бронь"
        "en"        "Armor"
        "fi"        "Suojaliivi"
    }
```
