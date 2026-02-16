#!/bin/bash
echo "removeing userPrefs"
rm -rf ~/.java/.userPrefs

echo "removeing evaluation key"
rm ~/.config/JetBrains/IntelliJIdea2021.2/eval/*.evaluation.key
# rm ~/.config/JetBrains/IntelliJIdea2020.3/eval/idea203.evaluation.key
# rm ~/.IntelliJIdea2019.1/config/eval/idea191.evaluation.key

echo "resetting evalsprt in options.xml"
sed -i '/evlsprt/d' ~/.config/JetBrains/IntelliJIdea2021.2/options/other.xml
# sed -i '/evlsprt/d' ~/.IntelliJIdea2019.1/config/options/other.xml

# echo "resetting evalsprt in prefs.xml"
# sed -i '/evlsprt/d' ~/.java/.userPrefs/prefs.xml
# sed -i '/JetBrains/d' ~/.java/.userPrefs/prefs.xml
