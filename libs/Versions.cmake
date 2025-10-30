######################################## Qt
if(NOT DEFINED QT)
	set(QT 6.9.2)
	set(QT_PATCHES ON)
endif()

if(NOT QT_HASH)
	set(QT_HASH_6.9.2 643f1fe35a739e2bf5e1a092cfe83dbee61ff6683684e957351c599767ca279c)

	set(QT_HASH ${QT_HASH_${QT}})
endif()



######################################## OpenSSL
if(NOT DEFINED OPENSSL)
	set(OPENSSL 3.5.4)
	set(OPENSSL_PATCHES ON)
endif()

if(NOT OPENSSL_HASH)
	set(OPENSSL_HASH_1.1.1w cf3098950cb4d853ad95c0841f1f9c6d3dc102dccfcacd521d93925208b76ac8)
	set(OPENSSL_HASH_3.0.18 d80c34f5cf902dccf1f1b5df5ebb86d0392e37049e5d73df1b3abae72e4ffe8b)
	set(OPENSSL_HASH_3.4.1 002a2d6b30b58bf4bea46c43bdd96365aaf8daa6c428782aa4feee06da197df3)
	set(OPENSSL_HASH_3.5.4 967311f84955316969bdb1d8d4b983718ef42338639c621ec4c34fddef355e99)

	set(OPENSSL_HASH ${OPENSSL_HASH_${OPENSSL}})
endif()
