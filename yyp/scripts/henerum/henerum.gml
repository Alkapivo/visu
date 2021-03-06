function applyHenerum() {

	var gridRenderer = getGridRenderer();
	
	gridRenderer.xScale = 1.07;
	gridRenderer.yScale = 1.07;
	gridRenderer.colorPrimaryLines = colorHashToColor("#f9ff21");
	gridRenderer.colorSecondaryLines = colorHashToColor("#c904b9");
	gridRenderer.colorGridWheelTopLeft = colorHashToColor("#f0f035");
	gridRenderer.colorGridWheelTopRight = colorHashToColor("#f0f035");
	gridRenderer.colorGridWheelBottomRight = colorHashToColor("#f0f035");
	gridRenderer.colorGridWheelBottomLeft = colorHashToColor("#c904b9");
	gridRenderer.shroom_texture_01 = asset_texture_henerum_1;
	gridRenderer.shroom_texture_02 = asset_texture_henerum_2;
	gridRenderer.shroom_texture_03 = asset_texture_henerum_3;
	gridRenderer.shroom_texture_04 = asset_texture_henerum_4;
	gridRenderer.shroom_texture_05 = asset_texture_henerum_5;
	gridRenderer.shroom_texture_06 = asset_texture_henerum_6;
	gridRenderer.shroom_texture_07 = asset_texture_henerum_7;
	gridRenderer.shroom_texture_08 = asset_texture_henerum_8;
	gridRenderer.background_texture_01 = asset_texture_henerum_bkg_1;
	gridRenderer.background_texture_02 = asset_texture_henerum_bkg_2;
	gridRenderer.background_texture_03 = asset_texture_henerum_bkg_3;
	gridRenderer.background_texture_04 = asset_texture_henerum_bkg_4;
	gridRenderer.background_color_01 = colorHashToGMColor("#000000");
	gridRenderer.background_color_02 = colorHashToGMColor("#e6d95e");
	gridRenderer.background_color_03 = colorHashToGMColor("#450e1c");
	gridRenderer.background_color_04 = colorHashToGMColor("#b01988");
}