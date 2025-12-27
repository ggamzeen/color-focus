# Algoritma Açıklaması

Proje, seçilen renge odaklanmak için hibrit bir maskeleme yöntemi kullanır.

## Adımlar
1. Görsel RGB uzayından HSV uzayına dönüştürülür.
2. Kullanıcının tıkladığı pikselin HSV değerleri alınır.
3. Dinamik toleranslar hesaplanır:
   - Hue toleransı
   - Saturation toleransı
   - Value toleransı
   - RGB mesafesi
   - Cosine similarity
4. Bu kriterlere göre maske oluşturulur.
5. Maske dışındaki alanlar griye çevrilir (`rgb2gray`).
6. Sonuç görseli kaydedilir.

## Avantajlar
- Renk algısı daha esnek.
- Düşük doygunlukta bile doğru seçim yapılabilir.
- Çıktı görselleri sunum için hazırdır.

