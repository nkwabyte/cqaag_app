import os
import glob

# Files to process
services = [
    'lib/services/membership/membership_service.dart',
    'lib/services/user/user_service.dart',
    'lib/services/auth/auth_service.dart'
]

for fp in services:
    with open(fp, 'r') as f:
        lines = f.readlines()
        
    out = []
    
    for l in lines:
        if 'await _connectivityService.ensureConnected();' in l:
            # For auth, keep ensure_connected only in methods touching auth token network etc,
            # wait, auth_service creates user docs. Let's just remove all for now, we can add it back if needed.
            # wait, auth actually signs in using Firebase Auth, which requires internet.
            pass
        else:
            out.append(l)
            
    with open(fp, 'w') as f:
        f.writelines(out)

print("Done")
