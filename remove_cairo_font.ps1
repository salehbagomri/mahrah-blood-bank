# قائمة الملفات التي تحتوي على fontFamily: 'Cairo'
$files = @(
    "D:\mahrah_blood_bank\lib\config\theme.dart",
    "D:\mahrah_blood_bank\lib\screens\home_screen.dart",
    "D:\mahrah_blood_bank\lib\screens\login_screen.dart",
    "D:\mahrah_blood_bank\lib\screens\onboarding_screen.dart",
    "D:\mahrah_blood_bank\lib\screens\otp_verification_screen.dart",
    "D:\mahrah_blood_bank\lib\screens\phone_input_screen.dart",
    "D:\mahrah_blood_bank\lib\screens\profile_screen.dart",
    "D:\mahrah_blood_bank\lib\screens\requests_list_screen.dart",
    "D:\mahrah_blood_bank\lib\screens\search_donors_screen.dart",
    "D:\mahrah_blood_bank\lib\screens\splash_screen.dart",
    "D:\mahrah_blood_bank\lib\widgets\custom_button.dart",
    "D:\mahrah_blood_bank\lib\widgets\custom_dropdown.dart",
    "D:\mahrah_blood_bank\lib\widgets\custom_text_field.dart"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        
        # إزالة fontFamily: 'Cairo',
        $content = $content -replace "fontFamily: 'Cairo',\s*\r?\n", ""
        
        # إزالة fontFamily: 'Cairo' (بدون فاصلة)
        $content = $content -replace "fontFamily: 'Cairo'", ""
        
        # حفظ الملف
        Set-Content -Path $file -Value $content -NoNewline
        
        Write-Host "✅ تم تحديث: $file"
    }
}

Write-Host "`n🎉 تم إزالة جميع fontFamily: 'Cairo' من الملفات!"
