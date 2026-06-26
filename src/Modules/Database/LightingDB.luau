local Lighting = game:GetService("Lighting")

export type LightingPreset = {
    --// Shape
    Ambient : Color3?;
    Brightness : number?;
    ColorShift_Bottom : Color3?;
    ColorShift_Top : Color3?;
    EnvironmentDiffuseScale : number?;
    EnvironmentSpecularScale : number?;
    GlobalShadows : boolean?;
    LightingStyle : Enum.LightingStyle?;
    OutdoorAmbient : Color3?;
    PrioritizeLightingQuality : boolean?;
    ShadowSoftness : number?;

    --// Data
    Archivable : boolean?;
    ClockTime : number?;
    GeographicLatitude : number?;
    TimeOfDay : string?;

    --// Exposure
    ExposureCompensation : number?;
}

local LightingDB : { [string]: LightingPreset } = {
    
    ["Default"] = { -- Roblox Default Lighting Setting
        --// Shape
        Ambient = Color3.fromRGB(70, 70, 70);
        Brightness = 3;
        ColorShift_Bottom = Color3.fromRGB(0, 0, 0);
        ColorShift_Top = Color3.fromRGB(0, 0, 0);
        EnvironmentDiffuseScale = 1;
        EnvironmentSpecularScale = 1;
        GlobalShadows = true;
        LightingStyle = Enum.LightingStyle.Soft;
        OutdoorAmbient = Color3.fromRGB(70, 70, 70);
        PrioritizeLightingQuality = true;
        ShadowSoftness = 0.2;

        --// Data
        Archivable = true;
        ClockTime = 14.5;
        GeographicLatitude = 0;
        TimeOfDay = "14:30:00";

        --// Exposure
        ExposureCompensation = 0;
    };

    ["Sol's RNG Lighting"] = {
        LightingStyle = Enum.LightingStyle.Realistic;
        ShadowSoftness = 0.2;
    };

}

--// 각 프리셋의 비어있는(nil) 속성을 "Default" 값으로 채운다.
for name, preset in LightingDB do
    if name == "Default" then continue end
    for key, value in LightingDB.Default do
        if preset[key] == nil then
            preset[key] = value
        end
    end
end

return LightingDB