import json

class Config:
    def __init__(self, clk_freq, new_file):
       self.clk_freq = clk_freq
       self.write_to_new_file = new_file 


def parse_config(f): 
    data = json.load(f)
    clk_freq = data['clockFrequency']
    new_file = data['writeToNewFile']
    return Config(clk_freq, new_file)
