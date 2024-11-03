local showDoorMessages = true

function SetShowDoorMessages(state)
    showDoorMessages = state
end

RegisterCommand('doors', function(source, args, rawCommand)
    local door = args[1] and string.lower(args[1])
    local playerPed = GetPlayerPed(-1)
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if not vehicle or vehicle == 0 then
        vehicle = GetClosestVehicle(GetEntityCoords(playerPed), 10.0)
    end

    if vehicle and vehicle ~= 0 then
        local doorIndex = GetDoorIndex(door)

        if doorIndex ~= nil then
            local formattedDoor = door:sub(1, 1):upper() .. door:sub(2)
            if IsVehicleDoorFullyOpen(vehicle, doorIndex) then
                SetVehicleDoorShut(vehicle, doorIndex, false)
                if showDoorMessages then
                    TriggerEvent('chat:addMessage', {
                        args = {formattedDoor .. ' is now closed.'}
                    })
                end
            else
                SetVehicleDoorOpen(vehicle, doorIndex, false, false)
                if showDoorMessages then
                    TriggerEvent('chat:addMessage', {
                        args = {formattedDoor .. ' is now opened.'}
                    })
                end
            end
        else
            TriggerEvent('chat:addMessage', {
                args = {'Invalid door type! Use Trunk, Hood, LeftFront, RightFront, LeftRear, or RightRear.'}
            })
        end
    else
        TriggerEvent('chat:addMessage', {
            args = {'No vehicle found nearby!'}
        })
    end
end, false)

function GetClosestVehicle(coords, radius)
    local vehicles = GetGamePool('CVehicle')
    local closestVehicle = nil
    local closestDistance = radius

    for _, vehicle in ipairs(vehicles) do
        local distance = #(coords - GetEntityCoords(vehicle))
        if distance < closestDistance then
            closestDistance = distance
            closestVehicle = vehicle
        end
    end

    return closestVehicle
end

function GetDoorIndex(door)
    if door == 'trunk' then
        return 5
    elseif door == 'hood' then
        return 4
    elseif door == 'leftfront' then
        return 0
    elseif door == 'rightfront' then
        return 1
    elseif door == 'leftrear' then
        return 2
    elseif door == 'rightrear' then
        return 3
    else
        return nil
    end
end

function IsVehicleDoorFullyOpen(vehicle, doorIndex)
    return GetVehicleDoorAngleRatio(vehicle, doorIndex) >= 0.50
end

-- Добавляем подсказку для команды /doors
TriggerEvent('chat:addSuggestion', '/doors', 'Doors management.', {
    { name = 'door', help = 'Type of door (Trunk, Hood, LeftFront, RightFront, LeftRear, RightRear)' }
})

AddEventHandler('chatMessage', function(source, name, message)
    if message == '/doors ' then
        TriggerEvent('chat:addMessage', {
            args = {'Available doors: Trunk, Hood, LeftFront, RightFront, LeftRear, RightRear.'}
        })
        CancelEvent()
    end
end)
