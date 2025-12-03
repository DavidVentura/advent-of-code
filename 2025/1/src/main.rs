use std::{
    error::Error,
    fs,
    io::{BufRead, BufReader},
};

fn main() -> Result<(), Box<dyn Error>> {
    let f = fs::File::open("problem.txt").unwrap();
    //let f = fs::File::open("example.txt").unwrap();
    let reader = BufReader::new(f);
    let start = 50;
    let mut position = start;
    let mut password = 0;
    let mut total_zeroes = 0;
    for line in reader.lines() {
        let line = line.unwrap();
        let mut direction = line;
        let count: u32 = direction.split_off(1).parse().unwrap();

        let dir_sign: i32 = match direction.as_str() {
            "L" => -1,
            "R" => 1,
            _ => panic!("Got {direction}"),
        };

        total_zeroes += count / 100;
        let mut remainder = count % 100;
        if dir_sign == -1 {
            if position >= remainder {
                position -= remainder;
            } else {
                if position != 0 {
                    total_zeroes += 1;
                }
                remainder -= position;
                position = 100;
                position -= remainder;
            }
        } else {
            if position + remainder > 100 {
                if position != 0 {
                    total_zeroes += 1;
                }
                remainder = position + remainder - 100;
                position = remainder;
            } else {
                position += remainder;
            }
        }

        if position == 100 {
            position = 0;
        }

        if position == 0 {
            password += 1;
        }
    }
    total_zeroes += password;
    println!("Password: {password}, total zeroes: {total_zeroes}");
    Ok(())
}
