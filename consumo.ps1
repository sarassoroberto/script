# URL locale del server web di Open Hardware Monitor
$ohmUrl = "http://localhost:8085/data.json"

while ($true) {
    try {
        # Scarica i dati JSON
        $json = Invoke-RestMethod -Uri $ohmUrl

        # Cerca i sensori di tipo 'Power'
        $powerSensors = $json.Children | ForEach-Object {
            $_.Children | ForEach-Object {
                $_.Sensors | Where-Object { $_.Type -eq "Power" }
            }
        }

        # Stampa i dati
        foreach ($sensor in $powerSensors) {
            Write-Host "$($sensor.Name): $($sensor.Value) $($sensor.Unit)"
        }

    } catch {
        Write-Host "Errore: $_"
    }

    Start-Sleep -Seconds 2
}
