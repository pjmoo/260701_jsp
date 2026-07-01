package com.example.jsp.step3;

public record Data2(String value1, int value2, boolean value3) {
    // getValue1을 찾는데 X
    // .value1()이 있고, getValue1은 없음

    // 직접 만들어야함
    public String getValue1() {
        return value1;
    }

    public int getValue2() {
        return value2;
    }

    public boolean getValue3() {
        return value3;
    }
}