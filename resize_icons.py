from PIL import Image
import os

# Input image
input_path = r"C:\Users\Administrator\.openclaw\media\tool-image-generation\image-1---d08f68e2-b7f4-44e8-934b-78326a0ceaa2.png"
output_dir = r"C:\extera-temp\android\app\src\main\res"

# Sizes for Android mipmap launcher icons
sizes = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

# Also create adaptive icon versions
adaptive_sizes = {
    "mipmap-anydpi-v26": 108,  # Adaptive icon foreground
}

img = Image.open(input_path)
if img.mode != 'RGBA':
    img = img.convert('RGBA')

# Resize to each mipmap size
for folder, size in sizes.items():
    folder_path = os.path.join(output_dir, folder)
    os.makedirs(folder_path, exist_ok=True)
    
    resized = img.resize((size, size), Image.Resampling.LANCZOS)
    resized.load()  # Load to finalize
    
    output_path = os.path.join(folder_path, "ic_launcher.png")
    resized.save(output_path, "PNG")
    print(f"Created {output_path} ({size}x{size})")

# Create adaptive icon foreground (108x108 with padding)
adaptive_size = 108
folder = "mipmap-anydpi-v26"
folder_path = os.path.join(output_dir, folder)
os.makedirs(folder_path, exist_ok=True)

# Create with transparency for adaptive icon
resized = img.resize((adaptive_size, adaptive_size), Image.Resampling.LANCZOS)
resized.save(os.path.join(folder_path, "ic_launcher.png"), "PNG")
print(f"Created adaptive icon foreground")

# Create a simple background for adaptive icon (solid color)
bg = Image.new('RGBA', (adaptive_size, adaptive_size), (224, 122, 61, 255))  # Orange primary color
bg.save(os.path.join(folder_path, "ic_launcher_background.png"), "PNG")
print(f"Created adaptive icon background")

print("Done!")
