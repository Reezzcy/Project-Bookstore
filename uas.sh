#!/bin/bash

function initBook {
    rm daftar-buku.txt
    echo "Algoritma dan Pemrograman;Rinaldi Munir;Informatika;5;50000" >> daftar-buku.txt
    echo "Atomic Habits;James Clear;Penguin Random House LLC;3;65000" >> daftar-buku.txt
    echo "Bumi;Tere Liye;Gramedia Pustaka Utama;3;45000" >> daftar-buku.txt
    echo "Kumpulan dan Solusi Pemrograman Python;Budi Raharjo;Informatika;1;45000" >> daftar-buku.txt
    echo "Sang Pemimpi;Andrea Hirata;Bentang Pusaka;5;40000" >> daftar-buku.txt
    echo "Laskar Pelangi;Andrea Hirata;Bentang Pusaka;6;40000" >> daftar-buku.txt
    echo "Negeri 5 Menara;Ahmad Fuadi;Gramedia Pustaka Utama;7;50000" >> daftar-buku.txt
    echo "Ayat-Ayat Cinta;Habiburrahman El Shirazy;Republika Penerbit;3;55000" >> daftar-buku.txt
}

keranjang=()
username=""

# Fungsi untuk menampilkan menu registrasi akun
function registrasi {
    echo "Registrasi Akun"
    echo -n "Masukkan username: "
    read -r username
    echo -n "Masukkan password: "
    read -r password

    if grep -q "$username;$password" user.txt; then
        echo "Registrasi gagal\n"
        registrasi
        return
    else
        echo "$username;$password" >> user.txt
        echo "Registrasi berhasil"
    fi
}

# Fungsi untuk menampilkan menu login
function login {
    echo "Login"
    echo -n "Masukkan username: "
    read -r username
    username=$username
    echo -n "Masukkan password: "
    read -r password
    if test ${#username} -eq 0 -a ${#password} -eq 0; then
        echo "Login gagal"
        login
        return
    elif grep -q "$username;$password" user.txt; then
        clear
        menu
    else
        echo "Login gagal"
        login
        return
    fi
}

# Fungsi untuk menampilkan menu beli
function beli {
    repeat="y"
    echo 
    echo "Katalog Buku"
    cat daftar-buku.txt
    echo
    echo "-------------------------------------"
    echo "Beli Buku"
    while [ $repeat == "y" ]; do
    echo -n "Masukkan kata kunci: "
    read -r keyword
    if cat daftar-buku.txt | cut -d";" -f1 | grep "$keyword"; then
        echo "-------------------------------------"
        echo -n "Masukkan nama buku: "
        read -r judul_beli
        info_buku=$(grep "$judul_beli" daftar-buku.txt)
        echo -n "Masukkan jumlah buku: "
        read -r jumlah
        if [ "$jumlah" -gt $(echo "$info_buku" | cut -d";" -f4) ]; then
            echo "Jumlah melebihi stok"
        else
            harga=$(echo "$info_buku" | cut -d";" -f5)
            keranjang+=("$username;$judul_beli;$jumlah;$harga")
            echo "Buku berhasil dimasukkan ke keranjang"

            stok_sekarang=$(( $(echo "$info_buku" | cut -d";" -f4) - "$jumlah" ))

            new_info_buku=$(echo "$info_buku" | sed "s/;\([0-9]\+\);/;$stok_sekarang;/")

            sed "s/$info_buku/$new_info_buku/" daftar-buku.txt >> new_daftar-buku.txt
            rm daftar-buku.txt && mv new_daftar-buku.txt daftar-buku.txt
        fi
        echo -n "Tambah buku lain ke dalam keranjang? (y/n): "
        read -r repeat
        echo "-------------------------------------"
    else
        echo "Buku tidak tersedia"
        break
    fi
    done
}

# Fungsi untuk menampilkan menu keranjang
function keranjang {
    echo "Keranjang"
    echo "Judul Buku | Jumlah Buku | Harga Buku | Total Harga"
    echo "--------------------------------------------------"

    for i in "${keranjang[@]}"; do
        judul_buku=$(echo "$i" | cut -d";" -f2)
        jumlah_buku=$(echo "$i" | cut -d";" -f3)
        harga_buku=$(echo "$i" | cut -d";" -f4)
        total_harga=$(( "$jumlah_buku" * "$harga_buku" ))
        echo "$judul_buku | $jumlah_buku | $harga_buku | $total_harga"
    done
}

# Fungsi untuk menampilkan menu proses transaksi
function proses_transaksi {
    echo "Transaksi Anda"
    echo "Atas nama: $username"
    echo "-------------------------------------"
    echo "Judul Buku | Jumlah Buku | Harga Buku | Total Harga"
    echo "--------------------------------------------------"

    # Mengecek apakah keranjang kosong
    if [ ${#keranjang[@]} -eq 0 ]; then
        echo "Keranjang kosong!"
        menu
        return
    fi

    for i in "${keranjang[@]}"; do
        judul_buku=$(echo "$i" | cut -d";" -f2)
        jumlah_buku=$(echo "$i" | cut -d";" -f3)
        harga_buku=$(echo "$i" | cut -d";" -f4)
        total_harga=$(( "$jumlah_buku" * "$harga_buku" ))
        echo "$judul_buku | $jumlah_buku | $harga_buku | $total_harga"
    done

    total_semua=0
    for i in "${keranjang[@]}"; do
        jumlah_buku=$(echo "$i" | cut -d";" -f3)
        harga_satuan=$(echo "$i" | cut -d";" -f4)
        harga_buku=$(( jumlah_buku * harga_satuan ))
        total_semua=$(( total_semua + harga_buku ))
    done
    echo "Total: $total_semua"

    echo -n "Apakah Anda ingin memproses transaksi? (y/n): "
    read -r pilihan
    if [ "$pilihan" == "y" ]; then
        echo "Transaksi berhasil"
        save_transaksi
        menu
    else
        echo "Transaksi dibatalkan"
        menu
    fi
}

function save_transaksi {
    for i in "${keranjang[@]}"; do
        echo "$i" >> transaksi.txt
    done
    keranjang=()
}

function menu {
    echo "Menu"
    echo "1. Beli Buku"
    echo "2. Keranjang"
    echo "3. Proses Transaksi"
    echo "0. Keluar"
    echo -n "Masukkan pilihan: "
    read -r pilihan
    case $pilihan in
        1) beli ; menu ;;
        2) keranjang ; menu ;;
        3) proses_transaksi ;;
        0) main ;;
        *) echo "Pilihan tidak tersedia" ; read ; clear ; menu ;;
    esac
}

function main {
    echo "Selamat datang di Toko Buku"
    echo "1. Registrasi"
    echo "2. Login"
    echo "0. Keluar"
    echo -n "Masukkan pilihan: "
    read -r pilihan
    case $pilihan in
        1) registrasi ; main ;;
        2) login ;;
        0) exit ;;
        *) echo "Pilihan tidak tersedia" ; read ;clear ; main ;;
    esac
}

initBook
main
