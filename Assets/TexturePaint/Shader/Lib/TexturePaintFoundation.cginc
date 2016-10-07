#ifndef TEXTURE_PAINT_FOUNDATION
#define TEXTURE_PAINT_FOUNDATION

//�y�C���g�u���V���`��͈͓����ǂ����𒲂ׂ�
bool IsPaintRange(float2 mainUV, float2 paintUV, float blushScale) {
	return
		paintUV.x - blushScale < mainUV.x &&
		mainUV.x < paintUV.x + blushScale &&
		paintUV.y - blushScale < mainUV.y &&
		mainUV.y < paintUV.y + blushScale;
}

//�`��͈͓��ŗ��p�ł���u���V�pUV���v�Z����
float2 CalcBlushUV(float2 mainUV, float2 paintUV, float blushScale) {
	return (paintUV.xy - mainUV) / blushScale * 0.5 + 0.5;
}

//���C���e�N�X�`���ƃu���V�̃u�����f�B���O�A���S���Y����TEXTURE_PAINT_COLOR_BLEND�ɐݒ�
#ifdef TEXTURE_PAINT_COLOR_BLEND_USE_CONTROL
	#define TEXTURE_PAINT_COLOR_BLEND(mainColor, blushColor, controlColor) TexturePaintColorBlendUseControl(mainColor, blushColor, controlColor)
#elif TEXTURE_PAINT_COLOR_BLEND_USE_BLUSH
	#define TEXTURE_PAINT_COLOR_BLEND(mainColor, blushColor, controlColor) TexturePaintColorBlendUseBlush(mainColor, blushColor, controlColor)
#elif TEXTURE_PAINT_COLOR_BLEND_NEUTRAL
	#define TEXTURE_PAINT_COLOR_BLEND(mainColor, blushColor, controlColor) TexturePaintColorBlendNeutral(mainColor, blushColor, controlColor)
#else
	#define TEXTURE_PAINT_COLOR_BLEND(mainColor, blushColor, controlColor) TexturePaintColorBlendUseControl(mainColor, blushColor, controlColor)
#endif

float4 ColorBlend(float4 targetColor, float4 mainColor, float blend) {
	return mainColor * (1 - blend) + targetColor * blend;
}

#define __COLOR_BLEND(targetColor) ColorBlend((targetColor), mainColor, blushColor.a)

//�u�����h��̐F���擾(�w��F���g��)
float4 TexturePaintColorBlendUseControl(float4 mainColor, float4 blushColor, float4 controlColor) {
	return __COLOR_BLEND(controlColor);
}

//�u�����h��̐F���擾(�u���V�e�N�X�`���F���g��)
float4 TexturePaintColorBlendUseBlush(float4 mainColor, float4 blushColor, float4 controlColor) {
	return __COLOR_BLEND(blushColor);
}

//�u�����h��̐F���擾(�w��F�ƃu���V�e�N�X�`���F�̒��ԐF)
float4 TexturePaintColorBlendNeutral(float4 mainColor, float4 blushColor, float4 controlColor) {
	return __COLOR_BLEND((blushColor + controlColor) * 0.5);
}

//�o���v�}�b�v�ƃu���V�̃u�����f�B���O�A���S���Y����TEXTURE_PAINT_BUMP_BLEND�ɐݒ�
#ifdef TEXTURE_PAINT_BUMP_BLEND_USE_BLUSH
	#define TEXTURE_PAINT_BUMP_BLEND(mainBump, blushBump, blend, blushAlpha) TexturePaintBumpBlendUseBlush(mainBump, blushBump, blend, blushAlpha)
#elif TEXTURE_PAINT_BUMP_BLEND_MIN
	#define TEXTURE_PAINT_BUMP_BLEND(mainBump, blushBump, blend, blushAlpha) TexturePaintBumpBlendMin(mainBump, blushBump, blend, blushAlpha)
#elif TEXTURE_PAINT_BUMP_BLEND_MAX
	#define TEXTURE_PAINT_BUMP_BLEND(mainBump, blushBump, blend, blushAlpha) TexturePaintBumpBlendMax(mainBump, blushBump, blend, blushAlpha)
#else
	#define TEXTURE_PAINT_BUMP_BLEND(mainBump, blushBump, blend, blushAlpha) TexturePaintBumpBlendLerp(mainBump, blushBump, blend, blushAlpha)
#endif

float4 BumpBlend(float4 targetBump,float4 mainBump, float blend, float blushAlpha) {
	return normalize(lerp(mainBump, targetBump * blushAlpha, blend));
}

#define __BUMP_BLEND(targetBump) BumpBlend((targetBump), mainBump, blend, blushAlpha)

//�o���v�}�b�v�u�����h��̒l���擾(���C���e�N�X�`���ƃu���V����)
float4 TexturePaintBumpBlendUseBlush(float4 mainBump, float4 blushBump, float blend, float blushAlpha) {
	return __BUMP_BLEND(blushBump);
}

//�o���v�}�b�v�u�����h��̒l���擾(�l�̒Ⴂ���ɕ��)
float4 TexturePaintBumpBlendMin(float4 mainBump, float4 blushBump, float blend, float blushAlpha) {
	return __BUMP_BLEND(min(mainBump, blushBump));
}

//�o���v�}�b�v�u�����h��̒l���擾(�l�̍������ɕ��)
float4 TexturePaintBumpBlendMax(float4 mainBump, float4 blushBump, float blend, float blushAlpha) {
	return __BUMP_BLEND(max(mainBump, blushBump));
}

#endif //TEXTURE_PAINT_FOUNDATION