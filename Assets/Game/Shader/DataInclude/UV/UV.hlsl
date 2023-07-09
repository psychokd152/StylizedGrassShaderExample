//UV - COMMON SHADER FUNCTIONS

//Flipbook
// void Unity_Flipbook(float2 UV, float Width, float Height, float Tile, float2 Invert, out float2 Out)
// {
//     Tile = fmod(Tile, Width * Height);
//     float2 tileCount = float2(1.0, 1.0) / float2(Width, Height);
//     float tileY = abs(Invert.y * Height - (floor(Tile * tileCount.x) + Invert.y * 1));
//     float tileX = abs(Invert.x * Width - ((Tile - Width * floor(Tile * tileCount.x)) + Invert.x * 1));
//     Out = (UV + float2(tileX, tileY)) * tileCount;
// }

//Polar Coordinates
float2 Unity_PolarCoordinates(float2 UV, float2 Center, float RadialScale, float LengthScale)
{
    float2 delta = UV - Center;
    float radius = length(delta) * 2 * RadialScale;
    float angle = atan2(delta.x, delta.y) * 1.0/6.28 * LengthScale;
    return float2(radius, angle);
}

//Rotate
float2 Unity_Rotate_Radians(float2 UV, float2 Center, float Rotation)
{
    UV -= Center;
    float s = sin(Rotation);
    float c = cos(Rotation);
    float2x2 rMatrix = float2x2(c, -s, s, c);
    rMatrix *= 0.5;
    rMatrix += 0.5;
    rMatrix = rMatrix * 2 - 1;
    UV.xy = mul(UV.xy, rMatrix);
    UV += Center;
    return UV;
}

float2 Unity_Rotate_Degrees(float2 UV, float2 Center, float Rotation)
{
    Rotation = Rotation * (3.1415926f/180.0f);
    UV -= Center;
    float s = sin(Rotation);
    float c = cos(Rotation);
    float2x2 rMatrix = float2x2(c, -s, s, c);
    rMatrix *= 0.5;
    rMatrix += 0.5;
    rMatrix = rMatrix * 2 - 1;
    UV.xy = mul(UV.xy, rMatrix);
    UV += Center;
    return UV;
}

//Triplanar

//Twirl
float2 Unity_Twirl_float(float2 UV, float2 Center, float Strength, float2 Offset)
{
    float2 delta = UV - Center;
    float angle = Strength * length(delta);
    float x = cos(angle) * delta.x - sin(angle) * delta.y;
    float y = sin(angle) * delta.x + cos(angle) * delta.y;
    return float2(x + Center.x + Offset.x, y + Center.y + Offset.y);
}