#!/usr/bin/env python3
"""
Create a rounded, glossy macOS app icon from the Vantageworks logo
"""

from PIL import Image, ImageDraw, ImageFilter
import numpy as np

def create_rounded_rectangle_mask(width, height, radius):
    """Create a mask for rounded rectangle"""
    mask = Image.new('L', (width, height), 0)
    draw = ImageDraw.Draw(mask)
    
    # Draw rounded rectangle
    draw.rounded_rectangle(
        [(0, 0), (width, height)], 
        radius=radius, 
        fill=255
    )
    
    return mask

def add_glossy_effect(image):
    """Add a glossy highlight effect to the image"""
    width, height = image.size
    
    # Create gradient for glossy effect
    gradient = Image.new('RGBA', (width, height), (255, 255, 255, 0))
    draw = ImageDraw.Draw(gradient)
    
    # Create top highlight
    for y in range(height // 2):
        alpha = int(80 * (1 - y / (height // 2)))
        color = (255, 255, 255, alpha)
        draw.rectangle([(0, y), (width, y + 1)], fill=color)
    
    # Blend with original image
    glossy = Image.alpha_composite(image, gradient)
    return glossy

def create_app_icon(input_path, output_path, size=512):
    """Create a rounded, glossy app icon"""
    # Load the original image
    original = Image.open(input_path)
    
    # Resize to desired size
    original = original.resize((size, size), Image.Resampling.LANCZOS)
    
    # Convert to RGBA if not already
    if original.mode != 'RGBA':
        original = original.convert('RGBA')
    
    # Create rounded mask (20% radius for nice macOS look)
    radius = int(size * 0.2)
    mask = create_rounded_rectangle_mask(size, size, radius)
    
    # Apply rounded mask
    rounded = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    rounded.paste(original, (0, 0))
    rounded.putalpha(mask)
    
    # Add glossy effect
    glossy = add_glossy_effect(rounded)
    
    # Add subtle shadow for depth
    shadow = Image.new('RGBA', (size + 20, size + 20), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle(
        [(5, 5), (size + 15, size + 15)], 
        radius=radius,
        fill=(0, 0, 0, 30)
    )
    
    # Blur the shadow
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=3))
    
    # Composite shadow with icon
    final = Image.new('RGBA', (size + 20, size + 20), (0, 0, 0, 0))
    final = Image.alpha_composite(final, shadow)
    final.paste(glossy, (10, 10), glossy)
    
    # Crop back to original size
    final = final.crop((10, 10, size + 10, size + 10))
    
    # Save as PNG
    final.save(output_path, 'PNG')
    print(f"✅ Created glossy icon: {output_path}")

if __name__ == "__main__":
    create_app_icon(
        'temp-icon.png',
        'glossy-icon.png',
        512
    )