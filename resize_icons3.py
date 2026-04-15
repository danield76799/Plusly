from PIL import Image
import os

# Input image - Daan's final logo (JPEG)
input_path = r"C:\Users\Administrator\.openclaw\media\inbound\file_175---4f59b685-6ef2-446f-bd34-15a747eaebb5.jpg"
output_dir = r"C:\extera-temp\android\app\src\main\res"

# Target size for adaptive icon (high quality)
target_size = 1024

img = Image.open(input_path)
print(f"Original size: {img.size}, mode: {img.mode}")

# Convert to RGBA if needed
if img.mode != 'RGBA':
    img = img.convert('RGBA')

# Resize to 1024x1024 keeping aspect ratio, then center crop
img.thumbnail((target_size, target_size), Image.Resampling.LANCZOS)

# Create 1024x1024 canvas and paste centered
new_img = Image.new('RGBA', (target_size, target_size), (0, 0, 0, 0))
x = (target_size - img.width) // 2
y = (target_size - img.height) // 2
new_img.paste(img, (x, y))

# Save as PNG for adaptive icon (CRITICAL: must be PNG for Android)
adaptive_path = os.path.join(output_dir, "mipmap-anydpi-v26", "ic_launcher.png")
new_img.save(adaptive_path, "PNG", quality=95)
print(f"Created adaptive icon: {adaptive_path} ({target_size}x{target_size})")

# Also create various sizes for other mipmap folders
sizes = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

for folder, size in sizes.items():
    folder_path = os.path.join(output_dir, folder)
    os.makedirs(folder_path, exist_ok=True)
    
    # Create small icon
    small_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    img_small = img.copy()
    img_small.thumbnail((size - 8, size - 8), Image.Resampling.LANCZOS)  # Leave some padding
    x = (size - img_small.width) // 2
    y = (size - img_small.height) // 2
    small_img.paste(img_small, (x, y))
    
    output_path = os.path.join(folder_path, "ic_launcher.png")
    small_img.save(output_path, "PNG")
    print(f"Created {output_path} ({size}x{size})")

# Web favicon - save as PNG
web_path = r"C:\extera-temp\web\favicon.png"
new_img.save(web_path, "PNG")
print(f"Created web favicon")

assets_path = r"C:\extera-temp\assets\favicon.png"
new_img.save(assets_path, "PNG")
print(f"Created assets favicon")

print("All done!")
