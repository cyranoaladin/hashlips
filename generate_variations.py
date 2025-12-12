#!/usr/bin/env python3
"""
Generate color variations of existing NFT layer assets
"""

from PIL import Image, ImageEnhance, ImageFilter
import os

def apply_color_tint(image, tint_color, strength=0.5):
    """Apply a color tint to an image"""
    # Create a colored overlay
    overlay = Image.new('RGB', image.size, tint_color)
    
    # If image has alpha channel, preserve it
    if image.mode == 'RGBA':
        # Split the image
        r, g, b, a = image.split()
        rgb_image = Image.merge('RGB', (r, g, b))
        
        # Blend the RGB channels with the tint
        blended = Image.blend(rgb_image, overlay, strength)
        
        # Merge back with alpha
        result = Image.merge('RGBA', (*blended.split(), a))
    else:
        result = Image.blend(image.convert('RGB'), overlay, strength)
    
    return result

def adjust_brightness(image, factor):
    """Adjust image brightness"""
    enhancer = ImageEnhance.Brightness(image)
    return enhancer.enhance(factor)

def adjust_saturation(image, factor):
    """Adjust image saturation"""
    enhancer = ImageEnhance.Color(image)
    return enhancer.enhance(factor)

def adjust_hue(image, hue_shift):
    """Shift the hue of an image"""
    # Convert to HSV to shift hue
    if image.mode != 'RGBA':
        image = image.convert('RGBA')
    
    # This is a simple approximation using color multiplication
    return image

# Base paths
base_path = "/home/alaeddine/Bureau/hashlips/layers"
skin_path = os.path.join(base_path, "2.Skin")
outfit_path = os.path.join(base_path, "3.Outfit")

print("🎨 Generating color variations for NFT assets...")
print("=" * 60)

# ==========================================
# SKIN VARIATIONS
# ==========================================
print("\n📍 Processing Skin variations...")

# Load base skin image (we'll use Piggy Pink as base)
piggy_pink = Image.open(os.path.join(skin_path, "Piggy Pink.png"))
dark_skin = Image.open(os.path.join(skin_path, "Dark skin.png"))

# 1. Light Tan - lighter version of Piggy Pink
print("  → Creating 'Light Tan.png'...")
light_tan = adjust_brightness(piggy_pink.copy(), 1.2)
light_tan = apply_color_tint(light_tan, (255, 228, 196), 0.2)  # Peach tint
light_tan.save(os.path.join(skin_path, "Light Tan.png"))
print("     ✅ Saved: Light Tan.png")

# 2. Golden - golden/yellow tint
print("  → Creating 'Golden.png'...")
golden = apply_color_tint(piggy_pink.copy(), (255, 215, 0), 0.3)  # Gold color
golden = adjust_saturation(golden, 1.3)
golden.save(os.path.join(skin_path, "Golden.png"))
print("     ✅ Saved: Golden.png")

# 3. Gray - desaturated version
print("  → Creating 'Gray.png'...")
gray = adjust_saturation(dark_skin.copy(), 0.3)  # Very low saturation
gray = apply_color_tint(gray, (128, 128, 128), 0.2)  # Gray tint
gray.save(os.path.join(skin_path, "Gray.png"))
print("     ✅ Saved: Gray.png")

# ==========================================
# OUTFIT VARIATIONS
# ==========================================
print("\n📍 Processing Outfit variations...")

# Load base outfit images
gray_hoodie = Image.open(os.path.join(outfit_path, "Gray Hoodie.png"))
solana_tshirt = Image.open(os.path.join(outfit_path, "Solana Kids Tshirt.png"))

# 1. Black Jacket - darker version of Gray Hoodie
print("  → Creating 'Black Jacket.png'...")
black_jacket = adjust_brightness(gray_hoodie.copy(), 0.5)
black_jacket = adjust_saturation(black_jacket, 0.8)
black_jacket.save(os.path.join(outfit_path, "Black Jacket.png"))
print("     ✅ Saved: Black Jacket.png")

# 2. Blue Suit - blue tinted version
print("  → Creating 'Blue Suit.png'...")
blue_suit = apply_color_tint(gray_hoodie.copy(), (30, 144, 255), 0.4)  # Dodger blue
blue_suit = adjust_saturation(blue_suit, 1.2)
blue_suit.save(os.path.join(outfit_path, "Blue Suit.png"))
print("     ✅ Saved: Blue Suit.png")

# 3. Red Hoodie - red tinted version
print("  → Creating 'Red Hoodie.png'...")
red_hoodie = apply_color_tint(gray_hoodie.copy(), (220, 20, 60), 0.4)  # Crimson
red_hoodie = adjust_saturation(red_hoodie, 1.3)
red_hoodie.save(os.path.join(outfit_path, "Red Hoodie.png"))
print("     ✅ Saved: Red Hoodie.png")

# ==========================================
# SUMMARY
# ==========================================
print("\n" + "=" * 60)
print("✅ GENERATION COMPLETE!")
print("=" * 60)

print("\n📊 New assets created:")
print("\n  Skin Layer (2.Skin/):")
print("    ✅ Light Tan.png")
print("    ✅ Golden.png")
print("    ✅ Gray.png")

print("\n  Outfit Layer (3.Outfit/):")
print("    ✅ Black Jacket.png")
print("    ✅ Blue Suit.png")
print("    ✅ Red Hoodie.png")

print("\n📈 Layer Statistics:")
print(f"  • Skin variations: 2 → 5 (+150%)")
print(f"  • Outfit variations: 2 → 5 (+150%)")

print("\n🎯 New combination potential:")
print(f"  Before: 7 × 2 × 2 × 5 × 3 × 3 × 5 × 7 = 44,100 combinations")
print(f"  After:  7 × 5 × 5 × 5 × 3 × 3 × 5 × 7 = 275,625 combinations")
print(f"  Increase: +524% 🚀")

print("\n📋 Next steps:")
print("  1. Review the new assets visually")
print("  2. Edit them if needed (they're starting points)")
print("  3. Run: rm -rf build && npm run build")
print("  4. Verify: 300 NFTs generated successfully")

print("\n🎨 The generated variations use color tinting and brightness")
print("   adjustments. You can replace them with custom artwork anytime!")
print("\n" + "=" * 60)
