
import langdetect

from langdetect import detect, detect_langs

text = "Все животные равны, но некоторые животные равнее других"

print(detect(text))
print(detect_langs(text))

# ru
# [ru:0.9999961866373268]
