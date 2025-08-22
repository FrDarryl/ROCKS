
propersID=$1;
echo "$propersID";
GetTomlText.sh ../toml/NOE_Propers-Sanctorale.toml "${propersID}.Entrance-Antiphon";
GetTomlText.sh ../toml/NOE_Propers-Sanctorale.toml "${propersID}.Collect";
GetTomlText.sh ../toml/NOE_Propers-Sanctorale.toml "${propersID}.Prayer-over-the-Offerings";
GetTomlText.sh ../toml/NOE_Propers-Sanctorale.toml "${propersID}.Communion-Antiphon";
GetTomlText.sh ../toml/NOE_Propers-Sanctorale.toml "${propersID}.Prayer-after-Communion";
