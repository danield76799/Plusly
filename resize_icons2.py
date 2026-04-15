from PIL import Image
import os

# Input image - Daan's original logo
input_path = r"C:\Users\Administrator\.openclaw\media\inbound\file_175---94a1a038-7749-4712-aa35-8870adf4c64e.jpg"
output_dir = r"C:\extera-temp\android\app\src\main\res"

# Target size for adaptive icon (high quality)
target_size = 1024

img = Image.open(input_path)
print(f"Original size: {img.size}, mode: {img.mode}")

# Resize to 1024x1024 keeping aspect ratio, then center crop
img.thumbnail((target_size, target_size), Image.Resampling.LANCZOS)

# Create 1024x1024 canvas and paste centered
new_img = Image.new('RGBA', (target_size, target_size), (0, 0, 0, 0))
x = (target_size - img.width) // 2
y = (target_size - img.height) // 2
new_img.paste(img, (x, y))

# Save as PNG for adaptive icon
adaptive_path = os.path.join(output_dir, "mipmap-anydpi-v26", "ic_launcher.png")
new_img.save(adaptive_path, "PNG", quality=95)
print(f"Created adaptive icon: {adaptive_path} ({target_size}x{target_size})")

# Also create various sizes for web favicon
web_path = r"C:\extera-temp\web\favicon.png"
new_img.save(web_path, "PNG")
print(f"Created web favicon")

assets_path = r"C:\extera-temp\assets\favicon.png"
new_img.save(assets_path, "PNG")
print(f"Created assets favicon")

print("Done!")
