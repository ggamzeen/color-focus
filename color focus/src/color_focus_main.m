function color_focus_main
    % Fotoğrafı seç
   % Proje kökünü bul (src'nin bir üstü)
projectRoot = fileparts(pwd);
dataDir = fullfile(projectRoot, 'data');

[filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp','Resim Dosyaları'}, ...
    'Bir görsel seçin', dataDir);


    if isequal(filename,0)
        disp('Kullanıcı iptal etti');
        return;
    end

    img = imread(fullfile(pathname, filename));
    imshow(img)
    title("Algılanacak renge tıklayın")

    % Kullanıcıdan tıklama al
    [x, y] = ginput(1);
    clickedRGB = double(squeeze(img(round(y), round(x), :)));
    clickedHSV = rgb2hsv(reshape(uint8(clickedRGB), [1 1 3]));

    % HSV bileşenleri
    pickedHue = clickedHSV(1);
    pickedSat = clickedHSV(2);
    pickedVal = clickedHSV(3);

    % 🔧 Dinamik toleransları fonksiyonla hesapla
    [hueTol, satTol, valTol, rgbTol, cosSimTol] = renkAlgilamaAyarla(pickedHue, pickedSat, pickedVal);

    % HSV dönüşümü
    hsvImg = rgb2hsv(img);
    H = hsvImg(:,:,1);
    S = hsvImg(:,:,2);
    V = hsvImg(:,:,3);

    % Hue çevrimsel farkı
    hueDiff = abs(H - pickedHue);
    hueDiff = min(hueDiff, 1 - hueDiff);

    % RGB renk mesafesi
    diffRGB = sqrt(sum((double(img) - double(reshape(clickedRGB,1,1,3))).^2, 3));

    % Normalize edilmiş renk yönü
    normImg = double(img) ./ (sqrt(sum(double(img).^2, 3)) + eps);
    normClicked = double(clickedRGB(:)') ./ (norm(double(clickedRGB)) + eps);
    cosSim = sum(normImg .* reshape(normClicked,1,1,3), 3);

    % Hibrit maske
    mask = (hueDiff < hueTol) & ...
           (abs(S - pickedSat) < satTol) & ...
           (abs(V - pickedVal) < valTol) & ...
           (diffRGB < rgbTol | cosSim > cosSimTol);

    % Basit maske genişletme (toolbox gerekmez)
    kernel = ones(3);
    mask = conv2(double(mask), kernel, 'same') > 0;

    % Gri arka plan
    grayImg = rgb2gray(img);
    grayImg = repmat(grayImg, [1 1 3]);

    % Sonuç
    result = grayImg;
    result(repmat(mask,[1 1 3])) = img(repmat(mask,[1 1 3]));

    figure;
    imshow(result)
    title("Seçilen renge göre algılanan görüntü (Akıllı Hibrit)")

    % --- 📂 Figures klasörüne kaydetme ---
    projectRoot = fileparts(pwd);              % src'nin bir üstüne çık
    figDir = fullfile(projectRoot, 'figures'); % ana klasördeki figures
    if ~exist(figDir, 'dir')
        mkdir(figDir);
    end

    [~, name, ~] = fileparts(filename);
i = 1;
savepath = fullfile(figDir, [name '_sonuc_' num2str(i) '.png']);
while exist(savepath,'file')
    i = i + 1;
    savepath = fullfile(figDir, [name '_sonuc_' num2str(i) '.png']);
end
imwrite(result, savepath);
end

% -------------------------------------------------------
% Fonksiyon: toleransları otomatik ayarlama
function [hueTol, satTol, valTol, rgbTol, cosSimTol] = renkAlgilamaAyarla(pickedHue, pickedSat, pickedVal)
    % Hue toleransı: uç renklerde genişletilir
    hueTol = max(0.04, min(0.10, 0.06 + 0.3 * (1 - abs(pickedHue - 0.5))));

    % Doygunluk ve parlaklık toleransları: düşükse genişletilir
    satTol = max(0.3, 0.5 + 0.5 * (1 - pickedSat));
    valTol = max(0.3, 0.5 + 0.5 * (1 - pickedVal));

    % RGB mesafesi toleransı: doygunluk düşükse artırılır
    rgbTol = 60 + 40 * (1 - pickedSat);

    % Renk yönü benzerliği (cosine similarity): düşük doygunlukta eşik düşürülür
    cosSimTol = 0.95 - 0.05 * (1 - pickedSat);
end

