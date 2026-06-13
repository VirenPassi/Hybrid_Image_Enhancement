from realesrgan import RealESRGAN
from PIL import Image
import torch
import sys

input_path = sys.argv[1]
output_path = sys.argv[2]

device = torch.device('cpu')

model = RealESRGAN(device, scale=4)
model.load_weights('RealESRGAN_x4.pth')

img = Image.open(input_path).convert('RGB')
sr_image = model.predict(img)

sr_image.save(output_path)