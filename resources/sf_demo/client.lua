local handle

CreateThread(function()
  handle = RequestScaleformMovie('SF_DEMO')
  while not HasScaleformMovieLoaded(handle) do
    Wait(0)
  end

  while true do
    DrawScaleformMovieFullscreen(handle, 255, 255, 255, 255, 0)
    Wait(0)
  end
end)

AddEventHandler('onResourceStop', function(resource)
  if resource ~= GetCurrentResourceName() or not handle then return end
  SetScaleformMovieAsNoLongerNeeded(handle)
end)
