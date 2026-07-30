# GitHub Pages yayın kurulumu

Bu depodaki `docs/` sayfaları herkese açık statik HTML olarak hazırlanmıştır;
ancak GitHub Pages etkinleştirilmeden canlı oldukları varsayılamaz.

1. GitHub deposunda **Settings → Pages** bölümünü açın.
2. Kaynak olarak **Deploy from a branch** seçin.
3. Yayın branch’i olarak değişiklikler merge edildikten sonra `main`, klasör
   olarak `/docs` seçin.
4. HTTPS zorlamasını etkinleştirin.
5. Aşağıdaki adreslerin HTTP 200 verdiğini gizli oturumda doğrulayın:
   - `https://leventua.github.io/BilgiRotasi/privacy-policy.html`
   - `https://leventua.github.io/BilgiRotasi/account-deletion.html`
   - `https://leventua.github.io/BilgiRotasi/terms-of-use.html`
   - `https://leventua.github.io/BilgiRotasi/community-guidelines.html`
6. Play Console’daki gizlilik politikası ve hesap silme alanlarına doğrulanmış
   HTTPS adreslerini girin.

Bu PR GitHub Pages ayarını değiştirmez; manuel etkinleştirme bekler.
