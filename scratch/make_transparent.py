import os
from PIL import Image

input_path = '/Users/mac/.gemini/antigravity-ide/brain/7451f69b-a197-4c5f-aa47-13770753effc/app_logo_white_1784902864395.png'
output_path = '/Users/mac/Public/flutter_projects/brokerhive/brokerflow-marketing/assets/logo/app_logo.png'

if not os.path.exists(input_path):
    print("Input image not found!")
    exit(1)

# Open image and convert to RGBA
img = Image.open(input_path).convert("RGBA")
datas = img.getdata()

newData = []
for item in datas:
    # item is a tuple (R, G, B, A)
    # If the pixel is very close to white, make it transparent
    r, g, b, a = item
    if r > 245 and g > 245 and b > 245:
        # Fully transparent
        newData.append((255, 255, 255, 0))
    elif r > 230 and g > 230 and b > 230:
        # Semi-transparent transition for anti-aliased edge smoothing
        diff = max(r, g, b) - 230
        alpha = int(255 * (1 - diff / 15.0))
        alpha = max(0, min(255, alpha))
        newData.append((r, g, b, alpha))
    else:
        newData.append(item)

img.putdata(newData)

# Crop the image to bounding box of non-transparent pixels to remove empty space around the logo
bbox = img.getbbox()
if bbox:
    img = img.crop(bbox)

# Save the resulting transparent logo
os.makedirs(os.path.dirname(output_path), exist_ok=True)
img.save(output_path, "PNG")
print("Successfully converted logo to transparent background and saved to:", output_path)
