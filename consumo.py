import wmi
import time

w = wmi.WMI(namespace="root\\wmi")

while True:
    try:
        bat = w.BatteryStatus()[0]
        voltage = bat.Voltage
        current = bat.DischargeRate
        watts = (voltage * current) / 1000000  # da µW a W
        print(f"Consumo: {watts:.2f} W")
    except:
        print("Dati non disponibili.")
    time.sleep(2)
