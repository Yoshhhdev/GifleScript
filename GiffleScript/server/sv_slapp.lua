RegisterServerEvent('JoJo:SyncSon_Serveur')
AddEventHandler('JoJo:SyncSon_Serveur', function()
    TriggerClientEvent('JoJo:SyncSon_Client', -1, source)
end)

RegisterServerEvent('JoJo:SyncGiffle')
AddEventHandler('JoJo:SyncGiffle', function(netID)
    TriggerClientEvent('JoJo:SyncAnimation', netID)
end)