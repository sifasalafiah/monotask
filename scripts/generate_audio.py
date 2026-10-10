import wave
import struct
import math
import random
import os

SAMPLE_RATE = 22050
OUT_DIR = "/Users/sifasalafiah/Documents/Project/monotask/assets/audio"
os.makedirs(OUT_DIR, exist_ok=True)

def write_wav(filename, samples):
    # samples: list of floats in [-1.0, 1.0]
    filepath = os.path.join(OUT_DIR, filename)
    with wave.open(filepath, 'w') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2) # 16-bit
        wf.setframerate(SAMPLE_RATE)
        
        # Crossfade start and end for seamless loop
        crossfade_len = int(SAMPLE_RATE * 0.5) # 0.5s crossfade
        total_len = len(samples)
        for i in range(crossfade_len):
            alpha = i / crossfade_len
            # Blend end into start
            end_idx = total_len - crossfade_len + i
            blended = samples[i] * alpha + samples[end_idx] * (1 - alpha)
            samples[i] = blended
            samples[end_idx] = blended

        raw_bytes = bytearray()
        for s in samples:
            val = max(-1.0, min(1.0, s))
            int_val = int(val * 32767)
            raw_bytes.extend(struct.pack('<h', int_val))
        wf.writeframes(raw_bytes)
    print(f"Generated {filepath} ({len(samples)/SAMPLE_RATE:.1f}s, {len(raw_bytes)} bytes)")

# 1. White / Pink Noise
def generate_white_noise(duration=10.0):
    num_samples = int(SAMPLE_RATE * duration)
    b0 = b1 = b2 = b3 = b4 = b5 = b6 = 0.0
    samples = []
    for _ in range(num_samples):
        white = random.uniform(-1, 1)
        # Paul Kellet's pink noise filter
        b0 = 0.99886 * b0 + white * 0.0555179
        b1 = 0.99332 * b1 + white * 0.0750759
        b2 = 0.96900 * b2 + white * 0.1538520
        b3 = 0.86650 * b3 + white * 0.3104856
        b4 = 0.55000 * b4 + white * 0.5329522
        b5 = -0.7616 * b5 - white * 0.0168980
        pink = b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362
        b6 = white * 0.115926
        samples.append(pink * 0.08)
    return samples

# 2. Rain Sound
def generate_rain(duration=10.0):
    num_samples = int(SAMPLE_RATE * duration)
    # Background steady pink noise rain
    base = generate_white_noise(duration)
    # Add drops
    num_drops = int(duration * 25) # 25 drops per sec
    for _ in range(num_drops):
        start_idx = random.randint(0, num_samples - 2000)
        freq = random.uniform(800, 1600)
        drop_len = random.randint(300, 900)
        vol = random.uniform(0.08, 0.22)
        for i in range(drop_len):
            env = math.exp(-i / (drop_len * 0.3))
            osc = math.sin(2 * math.pi * freq * (i / SAMPLE_RATE))
            base[start_idx + i] += osc * env * vol
    return base

# 3. Ocean Waves
def generate_waves(duration=12.0):
    num_samples = int(SAMPLE_RATE * duration)
    pink = generate_white_noise(duration)
    samples = []
    # 2 wave cycles over duration
    wave_period = duration / 2.0
    for i in range(num_samples):
        t = i / SAMPLE_RATE
        # Swell envelope
        envelope = (0.5 + 0.5 * math.sin(2 * math.pi * t / wave_period - math.pi/2)) ** 2
        # Low frequency rumble
        rumble = math.sin(2 * math.pi * 55 * t) * 0.05 * envelope
        samples.append(pink[i] * (0.15 + 0.85 * envelope) * 1.5 + rumble)
    return samples

# 4. Campfire
def generate_campfire(duration=10.0):
    num_samples = int(SAMPLE_RATE * duration)
    pink = generate_white_noise(duration)
    # Low flame hum
    samples = [p * 0.6 for p in pink]
    # Add random crackles and pops
    num_cracks = int(duration * 12)
    for _ in range(num_cracks):
        start_idx = random.randint(0, num_samples - 1500)
        pop_len = random.randint(150, 400)
        freq = random.uniform(350, 700)
        vol = random.uniform(0.25, 0.5)
        for i in range(pop_len):
            env = math.exp(-i / 40.0)
            osc = (random.uniform(-1, 1) * 0.7 + math.sin(2 * math.pi * freq * (i / SAMPLE_RATE)) * 0.3)
            samples[start_idx + i] += osc * env * vol
    return samples

# 5. Ambient Lo-Fi Chords
def generate_lofi(duration=16.0):
    num_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * num_samples
    
    # Chord progression: Dm7 (D3, F3, A3, C4) -> G7 (G2, B3, D4, F4) -> Cmaj7 (C3, E3, G3, B3) -> Am7 (A2, C3, E3, G3)
    chords = [
        [146.83, 174.61, 220.0, 261.63], # Dm7
        [98.0, 246.94, 293.66, 349.23],  # G7
        [130.81, 164.81, 196.0, 246.94], # Cmaj7
        [110.0, 130.81, 164.81, 196.0],  # Am7
    ]
    chord_duration = duration / len(chords)
    
    for c_idx, chord in enumerate(chords):
        start_time = c_idx * chord_duration
        start_sample = int(start_time * SAMPLE_RATE)
        end_sample = int((start_time + chord_duration) * SAMPLE_RATE)
        
        chord_len = end_sample - start_sample
        for f in chord:
            for i in range(chord_len):
                t = i / SAMPLE_RATE
                # Smooth bell-like envelope with warm sustain
                env = math.sin(math.pi * i / chord_len) ** 0.5
                # Warm sine wave + soft 2nd harmonic
                wave_val = math.sin(2 * math.pi * f * t) + 0.25 * math.sin(4 * math.pi * f * t)
                samples[start_sample + i] += wave_val * env * 0.04
                
    # Add subtle warm vinyl crackle/hiss
    for i in range(num_samples):
        samples[i] += random.uniform(-0.008, 0.008)
        
    return samples

if __name__ == '__main__':
    write_wav('white_noise.wav', generate_white_noise(10.0))
    write_wav('rain.wav', generate_rain(10.0))
    write_wav('waves.wav', generate_waves(12.0))
    write_wav('campfire.wav', generate_campfire(10.0))
    write_wav('lofi.wav', generate_lofi(16.0))
    print("All audio files generated successfully!")
