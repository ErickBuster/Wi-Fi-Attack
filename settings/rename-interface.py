#!/usr/bin/python
import os

new_interface=os.environ['new_interface']
old_interface=os.environ['old_interface']
print 'Renombrando la interfaz de red (' + old_interface + ')' + ": " + new_interface
os.system("sudo ifconfig " + old_interface + " down")
os.system("sudo ip link set " + old_interface + " name " + new_interface)
os.system("sudo ifconfig " + new_interface + " up")
print("Configuracion completada...")
