-- v1.0 spawn_ctl

Usage = {
        "USAGE: \n" ..
        "Please use the F10 Menu\n" ..
        "=======================\n" ..
        "1. Select number of enemies\n" ..
        "2. Select type of enemy aircraft\n" ..
        "3. Use the Command menu to 'Spawn Group'" ..
        "============================\n" ..
        "TIPS AND TRICKS\n" ..
        "- Set auto restart to reload th emission on death.\n" ..
        "- You can spawn multiple groups of different types at once for assured death!\n" ..
        "- Rearm / Refuel at Anapa-Vityazevo on Waypoint 2.\n" ..
        "\n=========================="
}

StateFlags = {
    ready = 3000,
    numberOfEnemies = 3001,
    enemyType = 3002,
    autoRestart = 3003,
    totalExisting = 3004,
    spawnFlag = 3005  -- Used in mission editor to spawn the group
}

-- enemyTypes
EnemyTypes = {
    F4 = 0,
    F16 = 1,
    F18 = 2,
    F15 = 3,
    F14 = 4,
    Su27 = 5,
    Su30 = 6,
    MiG29 =7,
    MiG31 =8,
    MiG21 =9,
    F5 = 10,
    A4 = 11
}

EnemyGroups = {
    [EnemyTypes.F4] = {
        id = 0,
        description = "F-4E",
        group_id = "Red-F-4E"
    },
    [EnemyTypes.F16] = {
        id = 1,
        description = "F-16A",
        group_id = "Red-F-16A"
    },
    [EnemyTypes.F18] = {
        id = 2,
        description = "F/A-18C",
        group_id = "Red-FA-18C"
    },
    [EnemyTypes.F15] = {
        id = 3,
        description = "F-15C",
        group_id = "Red-F-15C"
    },
    [EnemyTypes.F14] = {
        id = 4,
        description = "F-14B",
        group_id = "Red-F-14B"
    },
    [EnemyTypes.Su27] = {
        id = 5,
        description = "Su-27",
        group_id = "Red-Su-27"
    },
    [EnemyTypes.Su30] = {
        id = 6,
        description = "Su-30",
        group_id = "Red-Su-30"
    },
    [EnemyTypes.MiG29] = {
        id = 7,
        description = "MiG-29A",
        group_id = "Red-MiG29A"
    },
    [EnemyTypes.MiG31] = {
        id = 8,
        description = "MiG-31",
        group_id = "Red-MiG-31"
    },    
    [EnemyTypes.MiG21] = {
        id = 9,
        description = "MiG-21",
        group_id = "Red-MiG-21"
    },
    [EnemyTypes.F5] = {
        id = 10,
        description = "F-5E",
        group_id = "Red-F5E"
    },
    [EnemyTypes.A4] = {
        id = 11,
        description = "A-4E-C",
        group_id = "Red-A-4E-C"
    }
}

function showSpawnInfo()
    local numberOfEnemies = getUserFlag(StateFlags.numberOfEnemies)
    local enemyType = getUserFlag(StateFlags.enemyType)
    sendMessage_(
        "Current Spawn Details" ..
        "\n*****************" ..
        "\n# enemies : " .. numberOfEnemies ..
        "\nenemy type: " .. desc, 10
    )
end

function sendMessage_(msg, num)
    trigger.action.outText(msg, num)
end

function getUserFlag(flag)
    return trigger.misc.getUserFlag(flag)
end

function setUserFlag(flag, value)
    return trigger.action.setUserFlag(flag, value)
end

function setEnemyType(var)
    return trigger.action.setUserFlag(StateFlags.enemyType, var.type)
end

function setNumberOfEnemies(var)
    return trigger.action.setUserFlag(StateFlags.numberOfEnemies, var.noe)
end

function toggleAutoRestart()
    local currentState = getUserFlag(StateFlags.autoRestart)
    local nevValue = not currentState
    trigger.action.setUserFlag(StateFlags.autoRestart, currentState)
    local report = "Auto-restart is "
    if currentState then
        report = report .. "ON"
    else
        report = report .. "OFF"
    end
    sendMessage_(report)
end

function spawnGroup()
    local zone = "Red Spawn"
    local numberOfEnemies = getUserFlag(StateFlags.numberOfEnemies)
    local enemyType = getUserFlag(StateFlags.enemyType)
    local type = EnemyGroups[enemyType].id
    local desc = EnemyGroups[enemyType].description
    local grp =  EnemyGroups[enemyType].group_id
    sendMessage_(
        "New Spawn Details" ..
        "\n*****************" ..
        "\n# enemies : " .. numberOfEnemies ..
        "\nenemy type: " .. desc, 10
    )
    mist.respawnGroup(grp)
    for i = 1, numberOfEnemies -1 do
        mist.cloneGroup(grp, 1)
    end
end

function spawnRandomGroup()
    setUserFlag(StateFlags.numberOfEnemies, mist.random(1,4))
    setUserFlag(StateFlags.enemyType, mist.random(0,11))
    spawnGroup()
end

function initializeF10Menu()
    local countMenu = missionCommands.addSubMenu("Enemy Count")
    for i = 1, 4 do
        missionCommands.addCommand(i .. " v 1", countMenu, setNumberOfEnemies, {noe = i}) 
    end
    --type

    local enemiesNatoMenu = missionCommands.addSubMenu("Enemy Type-Nato")
    local enemiesEastBlockMenu = missionCommands.addSubMenu("Enemy Type-EastenBlock")
    
    for enemyType, enemyInfo in pairs(EnemyGroups) do
        local blockCode = string.sub(enemyInfo.description, 1,1)
        if blockCode == "F" or blockCode == "A" then
            missionCommands.addCommand(enemyInfo.description, enemiesNatoMenu, setEnemyType ,{type = enemyInfo.id} )
        else
            missionCommands.addCommand(enemyInfo.description, enemiesEastBlockMenu, setEnemyType ,{type = enemyInfo.id} )
        end
    end

    --Control
    local commandMenu = missionCommands.addSubMenu("Commands")
    local infoCmd = missionCommands.addCommand("Current Spawn Group Info", commandMenu, showSpawnInfo, { })
    local startCmd = missionCommands.addCommand("Spawn Group", commandMenu, spawnGroup, { })
    local startRandomCmd = missionCommands.addCommand("Spawn Random Group", commandMenu, spawnRandomGroup, { })
    local autoRestartCmd = missionCommands.addCommand("Auto-restart toggle", commandMenu, toggleAutoRestart, { })
    local helpCmd = missionCommands.addCommand("Help", commandMenu, sendMessage_, {Usage, 15}) 
end
-- Initialize default values as random values
-- setEnemyType(mist.random(0,9))
-- setNumberOfEnemies(mist.random(1,4)) 
-- setup menu itmes in f10
initializeF10Menu()
setUserFlag(StateFlags.ready,1)