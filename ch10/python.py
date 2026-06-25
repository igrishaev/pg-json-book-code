
import langdetect

from langdetect import detect, detect_langs

text = "Во поле берёза стояла."

print(detect(text))
print(detect_langs(text))

# ru
# [ru:0.9999961866373268]


import re

def to_tsquery(string, op='&'):
    words = re.split(r'[\s,]+', string)
    sep = " %s " % (op, )
    return sep.join([word.strip() for word in words])

print(to_tsquery("поле     береза кудрявая"))


# поле & береза & кудрявая
